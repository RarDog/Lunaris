import 'package:isar/isar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/result.dart';
import '../models/viewed_post.dart';

class ViewedPostRepository {
  ViewedPostRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<Result<void>> markViewed(String providerId, String postId) {
    return _databaseService.safeWrite((isar) async {
      final key = ViewedPost.keyFor(providerId, postId);
      await isar.viewedPostEntitys.put(
        ViewedPostEntity.fromModel(
          ViewedPost(
            viewedKey: key,
            providerId: providerId,
            postId: postId,
            viewedAt: DateTime.now(),
          ),
        ),
      );
    });
  }

  Future<Result<bool>> exists(String providerId, String postId) {
    return _databaseService.safeRead((isar) async {
      final entity = await isar.viewedPostEntitys
          .filter()
          .viewedKeyEqualTo(ViewedPost.keyFor(providerId, postId))
          .findFirst();
      return entity != null;
    });
  }

  Future<Result<Set<String>>> keys() {
    return _databaseService.safeRead((isar) async {
      final items = await isar.viewedPostEntitys.where().findAll();
      return items.map((item) => item.viewedKey).toSet();
    });
  }

  Future<Result<List<ViewedPost>>> recent() {
    return _databaseService.safeRead((isar) async {
      final items = await isar.viewedPostEntitys.where().findAll();
      items.sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
      return items.map((item) => item.toModel()).toList();
    });
  }

  Future<Result<void>> deleteItem(String providerId, String postId) {
    return _databaseService.safeWrite((isar) async {
      await isar.viewedPostEntitys.deleteByViewedKey(
        ViewedPost.keyFor(providerId, postId),
      );
    });
  }

  Future<Result<void>> clear() {
    return _databaseService.safeWrite((isar) async {
      await isar.viewedPostEntitys.clear();
    });
  }
}
