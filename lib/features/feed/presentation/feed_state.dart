import '../../../backend/backend.dart';

class FeedState {
  const FeedState({
    this.posts = const [],
    this.selectedTags = const [],
    this.selectedProviderIds = const [],
    this.ratingFilter,
    this.topPeriodFilter = TopPeriodFilter.none,
    this.tagSuggestions = const [],
    this.providers = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Post> posts;
  final List<String> selectedTags;
  final List<String> selectedProviderIds;
  final String? ratingFilter;
  final TopPeriodFilter topPeriodFilter;
  final List<String> tagSuggestions;
  final List<ContentProviderConfig> providers;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  FeedState copyWith({
    List<Post>? posts,
    List<String>? selectedTags,
    List<String>? selectedProviderIds,
    String? ratingFilter,
    TopPeriodFilter? topPeriodFilter,
    List<String>? tagSuggestions,
    bool clearRating = false,
    List<ContentProviderConfig>? providers,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedProviderIds: selectedProviderIds ?? this.selectedProviderIds,
      ratingFilter: clearRating ? null : ratingFilter ?? this.ratingFilter,
      topPeriodFilter: topPeriodFilter ?? this.topPeriodFilter,
      tagSuggestions: tagSuggestions ?? this.tagSuggestions,
      providers: providers ?? this.providers,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}
