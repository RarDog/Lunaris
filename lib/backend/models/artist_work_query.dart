class ArtistWorkQuery {
  const ArtistWorkQuery({
    required this.providerId,
    required this.service,
    required this.artistId,
    required this.artistName,
    this.queryText,
    this.tagFilter,
  });

  final String providerId;
  final String service;
  final String artistId;
  final String artistName;
  final String? queryText;
  final String? tagFilter;

  ArtistWorkQuery copyWith({
    String? providerId,
    String? service,
    String? artistId,
    String? artistName,
    String? queryText,
    String? tagFilter,
  }) {
    return ArtistWorkQuery(
      providerId: providerId ?? this.providerId,
      service: service ?? this.service,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      queryText: queryText ?? this.queryText,
      tagFilter: tagFilter ?? this.tagFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ArtistWorkQuery &&
        other.providerId == providerId &&
        other.service == service &&
        other.artistId == artistId &&
        other.artistName == artistName &&
        other.queryText == queryText &&
        other.tagFilter == tagFilter;
  }

  @override
  int get hashCode => Object.hash(
        providerId,
        service,
        artistId,
        artistName,
        queryText,
        tagFilter,
      );
}
