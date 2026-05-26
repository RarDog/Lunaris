import 'post.dart';

enum DownloadTaskStatus {
  queued,
  running,
  completed,
  failed,
  canceled,
}

class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.fileName,
    required this.progress,
    required this.status,
    this.post,
    this.sourceUrl,
    this.openAfterDownload = false,
    this.savedPath,
    this.error,
  });

  final String id;
  final Post? post;
  final String? sourceUrl;
  final String fileName;
  final double progress;
  final DownloadTaskStatus status;
  final bool openAfterDownload;
  final String? savedPath;
  final String? error;

  DownloadTask copyWith({
    double? progress,
    DownloadTaskStatus? status,
    String? savedPath,
    String? error,
  }) {
    return DownloadTask(
      id: id,
      post: post,
      sourceUrl: sourceUrl,
      fileName: fileName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      openAfterDownload: openAfterDownload,
      savedPath: savedPath ?? this.savedPath,
      error: error,
    );
  }
}
