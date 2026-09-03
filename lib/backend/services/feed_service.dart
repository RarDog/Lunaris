import '../../core/cache/cache_service.dart';
import '../../core/utils/result.dart';
import '../models/post.dart';
import '../models/top_period_filter.dart';
import '../providers/provider_manager.dart';
import '../services/viewed_history_service.dart';
import '../utils/smart_blacklist.dart';
import 'settings_service.dart';

class FeedService {
  FeedService(
    this._providerManager,
    this._cacheService,
    this._settingsService,
    this._viewedHistoryService,
  );

  final ProviderManager _providerManager;
  final CacheService _cacheService;
  final SettingsService _settingsService;
  final ViewedHistoryService _viewedHistoryService;
  final Map<String, int> _pages = {};

  String _key(
    List<String> tags,
    String? rating,
    String? providerId,
    TopPeriodFilter topPeriod,
  ) {
    final sorted = [...tags]..sort();
    return '${sorted.join(' ')}|${rating ?? ''}|${providerId ?? ''}|${topPeriod.name}';
  }

  Future<Result<List<Post>>> refresh({
    List<String> tags = const [],
    String? rating,
    String? providerId,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
    int limit = 50,
  }) {
    _pages[_key(tags, rating, providerId, topPeriod)] = 0;
    return loadNextPage(
      tags: tags,
      rating: rating,
      providerId: providerId,
      topPeriod: topPeriod,
      limit: limit,
    );
  }

  Future<Result<List<Post>>> loadNextPage({
    List<String> tags = const [],
    String? rating,
    String? providerId,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
    int limit = 50,
  }) async {
    final key = _key(tags, rating, providerId, topPeriod);
    final page = _pages[key] ?? 0;
    final result = await _providerManager.searchAcrossProviders(
      tags: tags,
      page: page,
      limit: limit,
      rating: rating,
      providerId: providerId,
      topPeriod: topPeriod,
    );
    if (result is Error<List<Post>>) return Error(result.failure);
    final posts = (result as Success<List<Post>>).data;
    _pages[key] = page + 1;
    final settingsResult = await _settingsService.getSettings();
    final settings = settingsResult is Success<AppSettings>
        ? settingsResult.data
        : AppSettings.defaults;
    final viewedKeysResult = settings.hideViewedPosts
        ? await _viewedHistoryService.getViewedKeys()
        : const Success(<String>{});
    final viewedKeys = viewedKeysResult is Success<Set<String>>
        ? viewedKeysResult.data
        : <String>{};
    final filteredPosts = _applyTopPeriod(posts, topPeriod)
        .where((post) => postMatchesRequestedTags(post, tags))
        .where((post) => postPassesTagFilters(post, settings))
        .where((post) =>
            !settings.hideViewedPosts || !viewedKeys.contains(post.cacheKey))
        .toList(growable: false);
    await _cacheService.cachePosts(
      filteredPosts,
      maxItems: settings.cacheMaxItems,
    );
    return Success(filteredPosts);
  }

  List<Post> _applyTopPeriod(List<Post> posts, TopPeriodFilter period) {
    if (period == TopPeriodFilter.none) return posts;

    final sorted = [...posts]..sort((a, b) => b.score.compareTo(a.score));
    if (period == TopPeriodFilter.allTime) return sorted;

    final now = DateTime.now();
    final minDate = period == TopPeriodFilter.month
        ? now.subtract(const Duration(days: 31))
        : DateTime(now.year - 1, now.month, now.day);
    final inPeriod = sorted
        .where((post) =>
            post.createdAt.isAfter(minDate) &&
            post.createdAt.isBefore(now.add(const Duration(days: 1))))
        .toList(growable: false);

    return inPeriod.isEmpty ? sorted : inPeriod;
  }
}

bool postMatchesRequestedTags(Post post, List<String> requestedTags) {
  final requested = requestedTags
      .map((tag) => tag.trim().toLowerCase())
      .where((tag) => tag.isNotEmpty && !tag.startsWith('-'))
      .toList(growable: false);
  if (requested.isEmpty) return true;
  final postTags = _postTagSet(post);
  return requested.every(
    (requestedTag) => postTags.any(
      (postTag) =>
          postTag == requestedTag ||
          postTag.startsWith('${requestedTag}_') ||
          postTag.startsWith('$requestedTag-'),
    ),
  );
}

bool postPassesTagFilters(Post post, AppSettings settings) {
  if (settings.hiddenPostKeys.contains(post.cacheKey)) return false;

  final tags = _postTagSet(post);
  if (tags.isEmpty) return settings.whitelistedTags.isEmpty;

  final blacklist = [
    ...settings.smartBlacklistRules,
    ...settings.blacklistedTags,
  ].map((tag) => tag.trim().toLowerCase()).where((tag) => tag.isNotEmpty);
  if (blacklist.any((rule) => SmartBlacklistMatcher.matches(post, rule))) {
    return false;
  }

  final whitelist = settings.whitelistedTags
      .map((tag) => tag.trim().toLowerCase())
      .where((tag) => tag.isNotEmpty)
      .toList(growable: false);
  if (whitelist.isEmpty) return true;
  return whitelist.any(tags.contains);
}

Set<String> _postTagSet(Post post) {
  return <String>{
    ...post.tags,
    for (final group in post.tagGroups.values) ...group,
  }
      .map((tag) => tag.trim().toLowerCase())
      .where((tag) => tag.isNotEmpty)
      .toSet();
}
