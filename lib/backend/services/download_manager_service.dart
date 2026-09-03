import 'dart:async';

import '../models/download_task.dart';
import '../models/post.dart';
import '../utils/media_quality.dart';
import 'download_service.dart';
import 'downloaded_media_service.dart';

class DownloadManagerService {
  DownloadManagerService(
    this._downloadService, {
    DownloadedMediaService? downloadedMediaService,
  }) : _downloadedMediaService = downloadedMediaService;

  final DownloadService _downloadService;
  final DownloadedMediaService? _downloadedMediaService;
  final _controller = StreamController<List<DownloadTask>>.broadcast();
  final Map<String, DownloadTask> _tasks = {};
  final Set<String> _runningTaskIds = {};
  bool _queuePaused = false;

  Stream<List<DownloadTask>> get stream => _controller.stream;
  List<DownloadTask> get tasks => List.unmodifiable(_tasks.values);
  bool get queuePaused => _queuePaused;

  Future<DownloadTask> start(Post post) async {
    final id = '${post.cacheKey}:${DateTime.now().microsecondsSinceEpoch}';
    final task = DownloadTask(
      id: id,
      post: post,
      fileName: _suggestedFileName(post),
      progress: 0,
      status: DownloadTaskStatus.queued,
    );
    _set(task);
    _pumpQueue();
    return task;
  }

  Future<DownloadTask> startUrl({
    required String url,
    required String fileName,
    bool openAfterDownload = false,
  }) async {
    final id = 'url:$url:${DateTime.now().microsecondsSinceEpoch}';
    final task = DownloadTask(
      id: id,
      sourceUrl: url,
      fileName: fileName,
      progress: 0,
      status: DownloadTaskStatus.queued,
      openAfterDownload: openAfterDownload,
    );
    _set(task);
    _pumpQueue();
    return task;
  }

  void pauseQueue() {
    _queuePaused = true;
    _emit();
  }

  void resumeQueue() {
    _queuePaused = false;
    _emit();
    _pumpQueue();
  }

  Future<void> retry(String taskId) async {
    final existing = _tasks[taskId];
    if (existing == null) return;
    final task = existing.copyWith(
      progress: 0,
      status: DownloadTaskStatus.queued,
      error: null,
    );
    _set(task);
    _pumpQueue();
  }

  void cancel(String taskId) {
    final existing = _tasks[taskId];
    if (existing == null) return;
    _set(existing.copyWith(status: DownloadTaskStatus.canceled));
  }

  void clearFinished() {
    _tasks.removeWhere(
      (_, task) =>
          task.status == DownloadTaskStatus.completed ||
          task.status == DownloadTaskStatus.failed ||
          task.status == DownloadTaskStatus.canceled,
    );
    _emit();
  }

  Future<void> _run(DownloadTask task) async {
    if (_tasks[task.id]?.status == DownloadTaskStatus.canceled) return;
    if (!_runningTaskIds.add(task.id)) return;
    _set(task.copyWith(status: DownloadTaskStatus.running));
    try {
      final saved = task.sourceUrl == null
          ? await _downloadService.downloadPost(
              task.post!,
              onProgress: (received, total) {
                _updateProgress(task.id, received, total);
              },
            )
          : await _downloadService.downloadUrl(
              task.sourceUrl!,
              fileName: task.fileName,
              mimeType: _mimeType(task.fileName),
              openAfterDownload: task.openAfterDownload,
              onProgress: (received, total) {
                _updateProgress(task.id, received, total);
              },
            );
      final current = _tasks[task.id];
      if (current == null || current.status == DownloadTaskStatus.canceled) {
        return;
      }
      _set(
        current.copyWith(
          progress: 1,
          status: DownloadTaskStatus.completed,
          savedPath: saved,
        ),
      );
      if (task.post != null && saved != null && saved.isNotEmpty) {
        await _downloadedMediaService?.markDownloaded(
          task.post!,
          savedPath: saved,
          fileName: task.fileName,
        );
      }
      _scheduleAutoRemove(task.id, const Duration(seconds: 6));
    } catch (error) {
      final current = _tasks[task.id];
      if (current == null || current.status == DownloadTaskStatus.canceled) {
        return;
      }
      _set(
        current.copyWith(
          status: DownloadTaskStatus.failed,
          error: error.toString(),
        ),
      );
    } finally {
      _runningTaskIds.remove(task.id);
      _pumpQueue();
    }
  }

  void _set(DownloadTask task) {
    _tasks[task.id] = task;
    _emit();
  }

  void _emit() {
    _controller.add(tasks);
  }

  void _pumpQueue() {
    if (_queuePaused) return;
    for (final task in tasks) {
      if (task.status != DownloadTaskStatus.queued) continue;
      if (_runningTaskIds.contains(task.id)) continue;
      unawaited(_run(task));
    }
  }

  void _updateProgress(String taskId, int received, int total) {
    if (total <= 0) return;
    final current = _tasks[taskId];
    if (current == null || current.status == DownloadTaskStatus.canceled) {
      return;
    }
    _set(current.copyWith(progress: received / total));
  }

  void _scheduleAutoRemove(String taskId, Duration delay) {
    Future<void>.delayed(delay, () {
      final current = _tasks[taskId];
      if (current?.status != DownloadTaskStatus.completed) return;
      _tasks.remove(taskId);
      _emit();
    });
  }

  String _suggestedFileName(Post post) {
    final url = MediaUrlSelector.download(post) ?? post.fileUrl;
    final parsed = Uri.tryParse(url);
    final last =
        parsed?.pathSegments.isEmpty ?? true ? '' : parsed!.pathSegments.last;
    if (last.contains('.')) return last;
    return '${post.providerId}_${post.id}';
  }

  String _mimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.apk')) {
      return 'application/vnd.android.package-archive';
    }
    if (lower.endsWith('.exe')) {
      return 'application/vnd.microsoft.portable-executable';
    }
    if (lower.endsWith('.zip')) {
      return 'application/zip';
    }
    return 'application/octet-stream';
  }
}
