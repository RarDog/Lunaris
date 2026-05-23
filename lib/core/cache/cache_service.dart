import 'package:isar/isar.dart';

import '../database/app_database.dart';
import '../database/database_service.dart';
import '../utils/result.dart';
import '../../backend/models/post.dart';

class CacheService {
  CacheService(this._databaseService);

  final DatabaseService _databaseService;

  Future<Result<void>> cachePosts(
    List<Post> posts, {
    int? maxItems,
  }) {
    return _databaseService.safeWrite((isar) async {
      await isar.cachedPostEntitys.putAll(
        posts.map((post) => CachedPostEntity.fromModel(post)).toList(),
      );
      if (maxItems != null && maxItems > 0) {
        await _evictOverflow(isar, maxItems);
      }
    });
  }

  Future<Result<List<Post>>> getCachedPosts({
    Duration maxAge = const Duration(hours: 24),
  }) {
    return _databaseService.safeRead((isar) async {
      final cutoff = DateTime.now().subtract(maxAge);
      final entities = await isar.cachedPostEntitys
          .filter()
          .cachedAtGreaterThan(cutoff)
          .findAll();
      entities.sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
      return entities.map((entity) => entity.toModel()).toList();
    });
  }

  Future<Result<void>> prune({
    Duration? olderThan,
    int? maxItems,
  }) {
    return _databaseService.safeWrite((isar) async {
      if (olderThan != null) {
        final cutoff = DateTime.now().subtract(olderThan);
        await isar.cachedPostEntitys
            .filter()
            .cachedAtLessThan(cutoff)
            .deleteAll();
      }
      if (maxItems != null && maxItems > 0) {
        await _evictOverflow(isar, maxItems);
      }
    });
  }

  Future<Result<void>> clear() {
    return _databaseService.safeWrite((isar) async {
      await isar.cachedPostEntitys.clear();
    });
  }

  Future<void> _evictOverflow(Isar isar, int maxItems) async {
    final entities = await isar.cachedPostEntitys.where().findAll();
    if (entities.length <= maxItems) return;
    entities.sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
    final overflowIds =
        entities.skip(maxItems).map((entity) => entity.isarId).toList();
    await isar.cachedPostEntitys.deleteAll(overflowIds);
  }
}
