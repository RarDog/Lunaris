import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import 'feed_state.dart';

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, FeedState>(FeedController.new);

class FeedController extends AsyncNotifier<FeedState> {
  @override
  Future<FeedState> build() async {
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
    state = const AsyncLoading();
    final posts = await _load(refresh: true, current: current);
    state = AsyncData(current.copyWith(posts: posts, clearError: true));
  }

  Future<void> refresh() async {
    final current = state.value ?? const FeedState();
    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    final posts = await _load(refresh: true, current: current);
    state = AsyncData(current.copyWith(posts: posts, isLoadingMore: false));
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    final posts = await _load(refresh: false, current: current);
    final existingKeys = current.posts.map((post) => post.cacheKey).toSet();
    final newPosts = posts
        .where((post) => existingKeys.add(post.cacheKey))
        .toList(growable: false);
    state = AsyncData(
      current.copyWith(
        posts: [...current.posts, ...newPosts],
        isLoadingMore: false,
        hasMore: posts.isNotEmpty,
      ),
    );
  }

  Future<void> search(String query) async {
    final tags = ref.read(searchServiceProvider).parseTags(query);
    final current = state.value ?? const FeedState();
    state = AsyncData(
      current.copyWith(selectedTags: tags, posts: [], tagSuggestions: []),
    );
    await saveSession(scrollOffset: 0);
    await ref.read(searchServiceProvider).saveSearch(query, 0);
    await refresh();
    final count = state.value?.posts.length ?? 0;
    await ref.read(searchServiceProvider).saveSearch(query, count);
  }

  Future<void> updateTagSuggestions(String query) async {
    final current = state.value ?? const FeedState();
    if (query.trim().isEmpty) {
      state = AsyncData(current.copyWith(tagSuggestions: []));
      return;
    }
    final lastToken = query.trim().split(RegExp(r'\s+')).last;
    final result = await ref
        .read(searchServiceProvider)
        .autocompleteDetailed(lastToken, limit: 16);
    final normalizedToken = lastToken.trim().toLowerCase();
    final suggestions = result is Success<List<TagSuggestion>>
        ? result.data
            .where((item) => item.name.toLowerCase().startsWith(
                  normalizedToken,
                ))
            .toList(growable: false)
        : const <TagSuggestion>[];
    state = AsyncData(current.copyWith(tagSuggestions: suggestions));
  }

  Future<void> setProviders(List<String> providerIds) async {
    final current = state.value ?? const FeedState();
    state = AsyncData(
        current.copyWith(selectedProviderIds: providerIds, posts: []));
    final settings = await _settings();
    await ref.read(settingsServiceProvider).updateSettings(
          settings.copyWith(
            selectedFeedProviderIds: providerIds,
            lastFeedProviderIds: providerIds,
          ),
        );
    await refresh();
  }

  Future<void> setTopPeriod(TopPeriodFilter period) async {
    final current = state.value ?? const FeedState();
    state = AsyncData(current.copyWith(topPeriodFilter: period, posts: []));
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
          ratingFilter: rating, clearRating: rating == null, posts: []),
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
    var index = 0;
    while (true) {
      var added = false;
      for (final group in providerResults) {
        if (index >= group.length) continue;
        final post = group[index];
        if (seen.add(post.cacheKey)) {
          posts.add(post);
          added = true;
        }
      }
      if (!added && providerResults.every((group) => index >= group.length)) {
        break;
      }
      index++;
    }
    return posts;
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
