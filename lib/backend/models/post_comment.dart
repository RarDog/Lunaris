class PostComment {
  const PostComment({
    required this.id,
    required this.postId,
    required this.providerId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String providerId;
  final String authorName;
  final String body;
  final DateTime createdAt;
}
