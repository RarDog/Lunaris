class DownloadedMedia {
  const DownloadedMedia({
    required this.cacheKey,
    required this.providerId,
    required this.postId,
    required this.savedPath,
    required this.fileName,
    required this.downloadedAt,
    required this.status,
  });

  final String cacheKey;
  final String providerId;
  final String postId;
  final String savedPath;
  final String fileName;
  final DateTime downloadedAt;
  final String status;
}
