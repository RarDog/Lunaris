import 'dart:io';

import '../../core/utils/result.dart';
import '../models/downloaded_media.dart';
import '../models/post.dart';
import '../repositories/downloaded_media_repository.dart';

class DownloadedMediaService {
  DownloadedMediaService(this._repository);

  final DownloadedMediaRepository _repository;

  Future<Result<void>> markDownloaded(
    Post post, {
    required String savedPath,
    required String fileName,
  }) {
    return _repository.markDownloaded(
      post,
      savedPath: savedPath,
      fileName: fileName,
    );
  }

  Future<Result<DownloadedMedia?>> getByCacheKey(String cacheKey) {
    return _repository.getByCacheKey(cacheKey);
  }

  Future<Result<Map<String, DownloadedMedia>>> allByKeys(
    Iterable<String> cacheKeys,
  ) {
    return _repository.allByKeys(cacheKeys);
  }

  Future<Result<void>> deleteLocalFile(String cacheKey) async {
    final result = await getByCacheKey(cacheKey);
    if (result is Error<DownloadedMedia?>) return Error(result.failure);
    final media = (result as Success<DownloadedMedia?>).data;
    if (media != null && media.savedPath.isNotEmpty) {
      final file = File(media.savedPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    return _repository.deleteRecord(cacheKey);
  }

  Future<Result<void>> clearMissingFiles() => _repository.clearMissingFiles();

  Future<Result<int>> count() => _repository.count();
}
