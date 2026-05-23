import 'package:isar/isar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/result.dart';
import '../models/post.dart';

class PostRepository {
  PostRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<Result<void>> cachePosts(List<Post> posts) {
    return _databaseService.safeWrite((isar) async {
      await isar.cachedPostEntitys.putAll(
        posts.map((post) => CachedPostEntity.fromModel(post)).toList(),
      );
    });
  }

  Future<Result<Post?>> getCachedPost(String postId, String providerId) {
    return _databaseService.safeRead((isar) async {
      final entity = await isar.cachedPostEntitys
          .filter()
          .providerIdEqualTo(providerId)
          .postIdEqualTo(postId)
          .findFirst();
      return entity?.toModel();
    });
  }

  Future<Result<List<Post>>> getCachedPostsByKeys(Iterable<String> keys) {
    return _databaseService.safeRead((isar) async {
      final posts = <Post>[];
      for (final key in keys) {
        final entity = await isar.cachedPostEntitys
            .filter()
            .cacheKeyEqualTo(key)
            .findFirst();
        if (entity != null) posts.add(entity.toModel());
      }
      return posts;
    });
  }
}
