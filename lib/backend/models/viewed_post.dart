class ViewedPost {
  const ViewedPost({
    required this.viewedKey,
    required this.providerId,
    required this.postId,
    required this.viewedAt,
  });

  final String viewedKey;
  final String providerId;
  final String postId;
  final DateTime viewedAt;

  static String keyFor(String providerId, String postId) =>
      '$providerId:$postId';
}
