class FavoriteArtistItem {
  const FavoriteArtistItem({
    required this.id,
    required this.service,
    required this.providerId,
    required this.name,
    this.avatarUrl,
  });

  const FavoriteArtistItem.empty()
      : id = '',
        service = '',
        providerId = '',
        name = '',
        avatarUrl = null;

  final String id;
  final String service;
  final String providerId;
  final String name;
  final String? avatarUrl;

  bool get isEmpty => id.isEmpty;
  String get key => '$providerId:$service:$id';

  Map<String, dynamic> toJson() => {
        'id': id,
        'service': service,
        'providerId': providerId,
        'name': name,
        'avatarUrl': avatarUrl,
      };

  factory FavoriteArtistItem.fromJson(Map<String, dynamic> json) =>
      FavoriteArtistItem(
        id: (json['id'] ?? '').toString(),
        service: (json['service'] ?? '').toString(),
        providerId: (json['providerId'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        avatarUrl: json['avatarUrl'] as String?,
      );

  FavoriteArtistItem copyWith({
    String? id,
    String? service,
    String? providerId,
    String? name,
    String? avatarUrl,
  }) {
    return FavoriteArtistItem(
      id: id ?? this.id,
      service: service ?? this.service,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteArtistItem &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}
