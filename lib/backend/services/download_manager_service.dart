import 'dart:async';

import '../models/download_task.dart';
import '../models/post.dart';
import '../utils/media_quality.dart';
import 'download_service.dart';

class DownloadManagerService {
  DownloadManagerService(this._downloadService);

  final DownloadService _downloadService;
  final _controller = StreamController<List<DownloadTask>>.broadcast();
  final Map<String, DownloadTask> _tasks = {};

  Stream<List<DownloadTask>> get stream => _controller.stream;
  List<DownloadTask> get tasks => List.unmodifiable(_tasks.values);

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
    unawaited(_run(task));
    return task;
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
    await _run(task);
  }

  void cancel(String taskId) {
    final existing = _tasks[taskId];
    if (existing == null) return;
    _set(existing.copyWith(status: DownloadTaskStatus.canceled));
  }

  Future<void> _run(DownloadTask task) async {
    if (_tasks[task.id]?.status == DownloadTaskStatus.canceled) return;
    _set(task.copyWith(status: DownloadTaskStatus.running));
    try {
      final saved = await _downloadService.downloadPost(
        task.post,
        onProgress: (received, total) {
          if (total <= 0) return;
          final current = _tasks[task.id];
          if (current == null ||
              current.status == DownloadTaskStatus.canceled) {
            return;
          }
          _set(current.copyWith(progress: received / total));
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
    }
  }

  void _set(DownloadTask task) {
    _tasks[task.id] = task;
    _controller.add(tasks);
  }

  void _scheduleAutoRemove(String taskId, Duration delay) {
    Future<void>.delayed(delay, () {
      final current = _tasks[taskId];
      if (current?.status != DownloadTaskStatus.completed) return;
      _tasks.remove(taskId);
      _controller.add(tasks);
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
}
