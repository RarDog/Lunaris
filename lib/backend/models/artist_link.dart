class ArtistLink {
  const ArtistLink({
    required this.id,
    required this.service,
    required this.name,
    this.publicId,
    this.indexed,
    this.updated,
  });

  final String id;
  final String service;
  final String name;
  final String? publicId;
  final DateTime? indexed;
  final DateTime? updated;

  factory ArtistLink.fromJson(Map<String, dynamic> json) {
    return ArtistLink(
      id: (json['id'] ?? '').toString(),
      service: (json['service'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      publicId: json['public_id']?.toString(),
      indexed: json['indexed'] != null
          ? DateTime.tryParse(json['indexed'].toString())
          : null,
      updated: json['updated'] != null
          ? DateTime.tryParse(json['updated'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'service': service,
        'name': name,
        if (publicId != null) 'public_id': publicId,
      };
}
