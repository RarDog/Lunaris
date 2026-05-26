import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/result.dart';
import '../models/downloaded_media.dart';
import '../models/post.dart';

class DownloadedMediaRepository {
  DownloadedMediaRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<Result<void>> markDownloaded(
    Post post, {
    required String savedPath,
    required String fileName,
    String status = 'downloaded',
  }) {
    return _databaseService.safeWrite((isar) async {
      await isar.downloadedMediaEntitys.put(
        DownloadedMediaEntity.fromModel(
          DownloadedMedia(
            cacheKey: post.cacheKey,
            providerId: post.providerId,
            postId: post.id,
            savedPath: savedPath,
            fileName: fileName,
            downloadedAt: DateTime.now(),
            status: status,
          ),
        ),
      );
    });
  }

  Future<Result<DownloadedMedia?>> getByCacheKey(String cacheKey) {
    return _databaseService.safeRead((isar) async {
      final entity = await isar.downloadedMediaEntitys
          .filter()
          .cacheKeyEqualTo(cacheKey)
          .findFirst();
      return entity?.toModel();
    });
  }

  Future<Result<Map<String, DownloadedMedia>>> allByKeys(
    Iterable<String> cacheKeys,
  ) {
    return _databaseService.safeRead((isar) async {
      final result = <String, DownloadedMedia>{};
      for (final key in cacheKeys) {
        final entity = await isar.downloadedMediaEntitys
            .filter()
            .cacheKeyEqualTo(key)
            .findFirst();
        if (entity != null) result[key] = entity.toModel();
      }
      return result;
    });
  }

  Future<Result<void>> deleteRecord(String cacheKey) {
    return _databaseService.safeWrite((isar) async {
      await isar.downloadedMediaEntitys
          .filter()
          .cacheKeyEqualTo(cacheKey)
          .deleteAll();
    });
  }

  Future<Result<void>> clearMissingFiles() {
    return _databaseService.safeWrite((isar) async {
      final items = await isar.downloadedMediaEntitys.where().findAll();
      for (final item in items) {
        if (item.savedPath.isEmpty || !File(item.savedPath).existsSync()) {
          await isar.downloadedMediaEntitys.delete(item.isarId);
        }
      }
    });
  }

  String fileNameForPath(String path) => p.basename(path);
}
