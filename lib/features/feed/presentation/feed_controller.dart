import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ratingFilter: settings.defaultRatingFilter,
      topPeriodFilter: TopPeriodFilter.values.firstWhere(
        (value) => value.name == settings.defaultTopPeriodFilter,
        orElse: () => TopPeriodFilter.none,
      ),
      selectedProviderIds:
          settings.selectedFeedProviderIds.where(providerIds.contains).toList(),
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
    state = AsyncData(
      current.copyWith(
        posts: [...current.posts, ...posts],
        isLoadingMore: false,
        hasMore: posts.isNotEmpty,
      ),
    );
  }

  Future<void> search(String query) async {
    final tags = ref.read(searchServiceProvider).parseTags(query);
    final current = state.value ?? const FeedState();
    state = AsyncData(current.copyWith(selectedTags: tags, posts: []));
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
    final result =
        await ref.read(searchServiceProvider).autocomplete(lastToken);
    final suggestions =
        result is Success<List<String>> ? result.data : const <String>[];
    state = AsyncData(current.copyWith(tagSuggestions: suggestions));
  }

  Future<void> setProviders(List<String> providerIds) async {
    final current = state.value ?? const FeedState();
    state = AsyncData(
        current.copyWith(selectedProviderIds: providerIds, posts: []));
    final settings = await _settings();
    await ref.read(settingsServiceProvider).updateSettings(
        settings.copyWith(selectedFeedProviderIds: providerIds));
    await refresh();
  }

  Future<void> setTopPeriod(TopPeriodFilter period) async {
    final current = state.value ?? const FeedState();
    state = AsyncData(current.copyWith(topPeriodFilter: period, posts: []));
    final settings = await _settings();
    await ref.read(settingsServiceProvider).updateSettings(
          settings.copyWith(defaultTopPeriodFilter: period.name),
        );
    await refresh();
  }

  Future<void> setRating(String? rating) async {
    final current = state.value ?? const FeedState();
    state = AsyncData(
      current.copyWith(
          ratingFilter: rating, clearRating: rating == null, posts: []),
    );
    await refresh();
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
    await ref
        .read(settingsServiceProvider)
        .updateSettings(settings.copyWith(selectedFeedProviderIds: []));
    await refresh();
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
      if (result is Success<List<Post>>) posts.addAll(result.data);
    }
    return posts;
  }

  Future<List<ContentProviderConfig>> _loadProviders() async {
    final result =
        await ref.read(providerManagerProvider).loadConfigs(enabledOnly: true);
    return result is Success<List<ContentProviderConfig>>
        ? result.data
        : const [];
  }

  Future<AppSettings> _settings() async {
    final result = await ref.read(settingsServiceProvider).getSettings();
    return result is Success<AppSettings> ? result.data : AppSettings.defaults;
  }
}
