class ArtistProfile {
  const ArtistProfile({
    required this.id,
    required this.providerId,
    required this.service,
    required this.name,
    required this.displayName,
    required this.url,
    this.avatarUrl,
    this.updatedAt,
    this.postCount,
  });

  final String id;
  final String providerId;
  final String service;
  final String name;
  final String displayName;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final int? postCount;
  final String url;
}
