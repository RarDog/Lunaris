import '../../core/cache/cache_service.dart';
import '../../core/utils/result.dart';
import '../models/post.dart';
import '../models/top_period_filter.dart';
import '../providers/provider_manager.dart';
import 'settings_service.dart';

class FeedService {
  FeedService(this._providerManager, this._cacheService, this._settingsService);

  final ProviderManager _providerManager;
  final CacheService _cacheService;
  final SettingsService _settingsService;
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
    final maxItems = settingsResult is Success<AppSettings>
        ? settingsResult.data.cacheMaxItems
        : null;
    await _cacheService.cachePosts(posts, maxItems: maxItems);
    return Success(posts);
  }
}
