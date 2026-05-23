class Favorite {
  const Favorite({
    required this.id,
    required this.postId,
    required this.providerId,
    required this.savedAt,
  });

  final String id;
  final String postId;
  final String providerId;
  final DateTime savedAt;
}
