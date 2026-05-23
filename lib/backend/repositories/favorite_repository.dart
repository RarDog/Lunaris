import 'package:isar/isar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/result.dart';
import '../models/favorite.dart';
import '../models/post.dart';
import 'post_repository.dart';

class FavoriteRepository {
  FavoriteRepository(this._databaseService, this._postRepository);

  final DatabaseService _databaseService;
  final PostRepository _postRepository;

  Future<Result<void>> add(Post post) async {
    await _postRepository.cachePosts([post]);
    return _databaseService.safeWrite((isar) async {
      final key = '${post.providerId}:${post.id}';
      await isar.favoriteEntitys.put(
        FavoriteEntity()
          ..favoriteKey = key
          ..favoriteId = key
          ..postId = post.id
          ..providerId = post.providerId
          ..savedAt = DateTime.now(),
      );
    });
  }

  Future<Result<void>> remove(String postId, String providerId) {
    return _databaseService.safeWrite((isar) async {
      await isar.favoriteEntitys
          .filter()
          .favoriteKeyEqualTo('$providerId:$postId')
          .deleteAll();
    });
  }

  Future<Result<bool>> exists(String postId, String providerId) {
    return _databaseService.safeRead((isar) async {
      return await isar.favoriteEntitys
              .filter()
              .favoriteKeyEqualTo('$providerId:$postId')
              .count() >
          0;
    });
  }

  Future<Result<List<Favorite>>> all() {
    return _databaseService.safeRead((isar) async {
      final items = await isar.favoriteEntitys.where().findAll();
      items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return items.map((entity) => entity.toModel()).toList();
    });
  }

  Future<Result<void>> clear() {
    return _databaseService.safeWrite((isar) async {
      await isar.favoriteEntitys.clear();
    });
  }
}
