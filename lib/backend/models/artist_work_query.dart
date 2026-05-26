class ArtistWorkQuery {
  const ArtistWorkQuery({
    required this.providerId,
    required this.service,
    required this.artistId,
    required this.artistName,
  });

  final String providerId;
  final String service;
  final String artistId;
  final String artistName;

  @override
  bool operator ==(Object other) {
    return other is ArtistWorkQuery &&
        other.providerId == providerId &&
        other.service == service &&
        other.artistId == artistId &&
        other.artistName == artistName;
  }

  @override
  int get hashCode => Object.hash(providerId, service, artistId, artistName);
}
