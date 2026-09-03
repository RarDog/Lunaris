import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import 'feed_state.dart';

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, FeedState>(FeedController.new);

class FeedController extends AsyncNotifier<FeedState> {
  Timer? _providerDebounce;
  Timer? _suggestionDebounce;
  StreamSubscription<ProviderSoftRetryResult>? _softRetrySubscription;
  int _loadRequestId = 0;
  int _suggestionRequestId = 0;

  @override
  Future<FeedState> build() async {
    ref.onDispose(() {
      _providerDebounce?.cancel();
      _suggestionDebounce?.cancel();
      _softRetrySubscription?.cancel();
    });
    _softRetrySubscription ??= ref
        .read(providerManagerProvider)
        .softRetryResults
        .listen(_applySoftRetryResult);
    final providers = await _loadProviders();
    final settings = await _settings();
    final providerIds = providers.map((provider) => provider.id).toSet();
    final initial = FeedState(
      providers: providers,
      topPeriodFilter: TopPeriodFilter.values.firstWhere(
        (value) => value.name == settings.lastFeedTopPeriod,
        orElse: () => TopPeriodFilter.none,
      ),
      selectedTags: settings.lastFeedTags,
      selectedProviderIds:
          settings.lastFeedProviderIds.where(providerIds.contains).toList(),
      ratingFilter: settings.lastFeedRating ?? settings.defaultRatingFilter,
    );
    state = AsyncData(initial);
    await loadInitial();
    return state.value ?? initial;
  }

  Future<void> loadInitial() async {
    final current = state.value ?? const FeedState();
    final requestId = ++_loadRequestId;
    state = const AsyncLoading();
    final posts = await _load(refresh: true, current: current);
    if (requestId != _loadRequestId) return;
    state = AsyncData(current.copyWith(
      posts: posts,
      hasMore: true,
      emptyPageStreak: 0,
      clearError: true,
      providerStatusMessage: await _providerStatusMessage(current),
    ));
  }

  Future<void> refresh() async {
    final current = state.value ?? const FeedState();
    final requestId = ++_loadRequestId;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    final posts = await _load(refresh: true, current: current);
    if (requestId != _loadRequestId) return;
    state = AsyncData(current.copyWith(
      posts: posts,
      isLoadingMore: false,
      hasMore: true,
      emptyPageStreak: 0,
      providerStatusMessage: await _providerStatusMessage(current),
    ));
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    final requestId = ++_loadRequestId;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    final posts = <Post>[];
    const maxEmptyPageSkips = 3;
    var attempts = 0;
    while (posts.isEmpty && attempts < maxEmptyPageSkips) {
      attempts++;
      posts.addAll(await _load(refresh: false, current: current));
      if (requestId != _loadRequestId) return;
    }
    if (requestId != _loadRequestId) return;
    final existingKeys = current.posts.map((post) => post.cacheKey).toSet();
    final newPosts = posts
        .where((post) => existingKeys.add(post.cacheKey))
        .toList(growable: false);
    final emptyPageStreak =
        newPosts.isEmpty ? current.emptyPageStreak + attempts : 0;
    state = AsyncData(
      current.copyWith(
        posts: [...current.posts, ...newPosts],
        isLoadingMore: false,
        hasMore: newPosts.isNotEmpty || emptyPageStreak < maxEmptyPageSkips,
        emptyPageStreak: emptyPageStreak,
      ),
    );
  }

  Future<void> search(String query) async {
    final tags = ref.read(searchServiceProvider).parseTags(query);
    final current = state.value ?? const FeedState();
    state = AsyncData(
      current.copyWith(
        selectedTags: tags,
        posts: [],
        tagSuggestions: [],
        hasMore: true,
        emptyPageStreak: 0,
      ),
    );
    await saveSession(scrollOffset: 0);
    final settingsRes = await ref.read(settingsServiceProvider).getSettings();
    final settings =
        settingsRes is Success<AppSettings> ? settingsRes.data : AppSettings.defaults;
    await ref
        .read(searchServiceProvider)
        .saveSearch(query, 0, maxHistory: settings.searchHistoryLimit);
    await refresh();
    final count = state.value?.posts.length ?? 0;
    await ref
        .read(searchServiceProvider)
        .saveSearch(query, count, maxHistory: settings.searchHistoryLimit);
  }

  Future<void> updateTagSuggestions(String query) async {
    final current = state.value ?? const FeedState();
    final rawLast =
        query.trim().isEmpty ? '' : query.trim().split(RegExp(r'\s+')).last;
    final cleanToken = SearchService.sanitizeToken(rawLast);
    final requestId = ++_suggestionRequestId;
    _suggestionDebounce?.cancel();

    if (cleanToken.isEmpty || cleanToken == 'and') {
      state = AsyncData(current.copyWith(tagSuggestions: []));
      return;
    }

    // Instant local suggestions from disk cache & history (0 ms)
    final localMatches = ref
        .read(searchServiceProvider)
        .instantSuggestions(cleanToken, limit: 16);
    if (localMatches.isNotEmpty) {
      state = AsyncData(current.copyWith(tagSuggestions: localMatches));
    }

    _suggestionDebounce = Timer(const Duration(milliseconds: 160), () async {
      final settingsRes = await ref.read(settingsServiceProvider).getSettings();
      final appSettings = settingsRes is Success<AppSettings>
          ? settingsRes.data
          : AppSettings.defaults;
      final result = await ref
          .read(searchServiceProvider)
          .autocompleteDetailed(
            cleanToken,
            limit: 16,
            tagCacheLimit: appSettings.tagCacheLimit,
          );
      if (requestId != _suggestionRequestId) return;
      final suggestions = result is Success<List<TagSuggestion>>
          ? result.data
          : localMatches;
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(tagSuggestions: suggestions));
    });
  }

  Future<void> setProviders(List<String> providerIds) async {
    final current = state.value ?? const FeedState();
    final enabledIds = current.providers.map((provider) => provider.id).toSet();
    final selected = providerIds.where(enabledIds.contains).toList();
    state = AsyncData(current.copyWith(
      selectedProviderIds: selected,
      posts: [],
      hasMore: true,
      emptyPageStreak: 0,
    ));
    final settings = await _settings();
    await ref.read(settingsServiceProvider).updateSettings(
          settings.copyWith(
            selectedFeedProviderIds: selected,
            lastFeedProviderIds: selected,
          ),
        );
    _providerDebounce?.cancel();
    _providerDebounce = Timer(const Duration(milliseconds: 320), () {
      refresh();
    });
  }

  Future<void> setTopPeriod(TopPeriodFilter period) async {
    final current = state.value ?? const FeedState();
    state = AsyncData(current.copyWith(
      topPeriodFilter: period,
      posts: [],
      hasMore: true,
      emptyPageStreak: 0,
    ));
    final settings = await _settings();
    await ref.read(settingsServiceProvider).updateSettings(
          settings.copyWith(defaultTopPeriodFilter: period.name),
        );
    await saveSession(scrollOffset: 0);
    await refresh();
  }

  Future<void> setRating(String? rating) async {
    final current = state.value ?? const FeedState();
    state = AsyncData(
      current.copyWith(
        ratingFilter: rating,
        clearRating: rating == null,
        posts: [],
        hasMore: true,
        emptyPageStreak: 0,
      ),
    );
    await refresh();
    await saveSession(scrollOffset: 0);
  }

  Future<void> clearFilters() async {
    final current = state.value ?? const FeedState();
    state = AsyncData(
      current.copyWith(
        selectedTags: [],
        selectedProviderIds: [],
        tagSuggestions: [],
        clearRating: true,
        posts: [],
        hasMore: true,
        emptyPageStreak: 0,
      ),
    );
    final settings = await _settings();
    await ref.read(settingsServiceProvider).updateSettings(settings.copyWith(
          selectedFeedProviderIds: [],
          lastFeedTags: [],
          lastFeedProviderIds: [],
          clearLastFeedRating: true,
          lastFeedTopPeriod: TopPeriodFilter.none.name,
          lastFeedScrollOffset: 0,
        ));
    await refresh();
  }

  Future<void> hidePost(Post post) async {
    final current = state.value;
    if (current == null) return;
    final result =
        await ref.read(settingsServiceProvider).hidePostKey(post.cacheKey);
    if (result is Error<void>) return;
    state = AsyncData(
      current.copyWith(
        posts: current.posts
            .where((item) => item.cacheKey != post.cacheKey)
            .toList(growable: false),
      ),
    );
    ref.invalidate(appSettingsProvider);
  }

  Future<void> saveSession({double? scrollOffset}) async {
    final current = state.value;
    if (current == null) return;
    final settings = await _settings();
    await ref.read(settingsServiceProvider).updateSettings(
          settings.copyWith(
            lastFeedTags: current.selectedTags,
            lastFeedProviderIds: current.selectedProviderIds,
            lastFeedRating: current.ratingFilter,
            lastFeedTopPeriod: current.topPeriodFilter.name,
            lastFeedScrollOffset: scrollOffset ?? settings.lastFeedScrollOffset,
          ),
        );
  }

  Future<List<Post>> _load({
    required bool refresh,
    required FeedState current,
  }) async {
    final service = ref.read(feedServiceProvider);
    final providerIds = current.selectedProviderIds.isEmpty
        ? <String?>[null]
        : current.selectedProviderIds;
    final posts = <Post>[];
    final providerResults = <List<Post>>[];
    for (final providerId in providerIds) {
      final result = refresh
          ? await service.refresh(
              tags: current.selectedTags,
              rating: current.ratingFilter,
              providerId: providerId,
              topPeriod: current.topPeriodFilter,
            )
          : await service.loadNextPage(
              tags: current.selectedTags,
              rating: current.ratingFilter,
              providerId: providerId,
              topPeriod: current.topPeriodFilter,
            );
      if (result is Success<List<Post>>) {
        providerResults.add(result.data);
      }
    }
    final seen = <String>{};
    if (providerResults.length <= 1) {
      for (final group in providerResults) {
        for (final post in group) {
          if (seen.add(post.cacheKey)) posts.add(post);
        }
      }
      return posts;
    }
    for (final group in providerResults) {
      for (final post in group) {
        if (seen.add(post.cacheKey)) posts.add(post);
      }
    }
    posts.sort((a, b) => _mixKey(a).compareTo(_mixKey(b)));
    return posts;
  }

  void _applySoftRetryResult(ProviderSoftRetryResult result) {
    final current = state.value;
    if (current == null || result.page != 0) return;
    if (!_sameTags(current.selectedTags, result.tags)) return;
    if (current.ratingFilter != result.rating) return;
    if (current.topPeriodFilter != result.topPeriod) return;
    if (current.selectedProviderIds.isNotEmpty &&
        !current.selectedProviderIds.contains(result.providerId)) {
      return;
    }
    final seen = current.posts.map((post) => post.cacheKey).toSet();
    final newPosts = result.posts
        .where((post) => seen.add(post.cacheKey))
        .toList(growable: false);
    if (newPosts.isEmpty) return;
    state = AsyncData(
      current.copyWith(
        posts: [...current.posts, ...newPosts]..sort(
            (a, b) => _mixKey(a).compareTo(_mixKey(b)),
          ),
        providerStatusMessage: 'Retry added ${newPosts.length} posts',
      ),
    );
  }

  bool _sameTags(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  Future<String?> _providerStatusMessage(FeedState current) async {
    final result = await ref.read(providerRepositoryProvider).getDiagnostics();
    if (result is! Success<List<ProviderDiagnostics>>) return null;
    final selected = current.selectedProviderIds.isEmpty
        ? current.providers.map((provider) => provider.id).toSet()
        : current.selectedProviderIds.toSet();
    final failed = result.data
        .where((item) =>
            selected.contains(item.providerId) &&
            item.lastErrorMessage != null &&
            item.lastErrorMessage!.isNotEmpty)
        .map((item) => item.providerId)
        .toSet();
    if (failed.isEmpty) return null;
    return 'Retrying ${failed.length} provider${failed.length == 1 ? '' : 's'}';
  }

  int _mixKey(Post post) {
    var hash = 0x811c9dc5;
    for (final code in post.cacheKey.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  Future<List<ContentProviderConfig>> _loadProviders() async {
    final result = await ref
        .read(providerManagerProvider)
        .loadFeedConfigs(enabledOnly: true);
    return result is Success<List<ContentProviderConfig>>
        ? result.data
        : const [];
  }

  Future<AppSettings> _settings() async {
    final result = await ref.read(settingsServiceProvider).getSettings();
    return result is Success<AppSettings> ? result.data : AppSettings.defaults;
  }
}
