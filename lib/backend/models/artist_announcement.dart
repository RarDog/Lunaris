class ArtistAnnouncement {
  const ArtistAnnouncement({
    required this.service,
    required this.userId,
    required this.content,
    this.hash,
    this.added,
  });

  final String service;
  final String userId;
  final String content;
  final String? hash;
  final DateTime? added;

  factory ArtistAnnouncement.fromJson(Map<String, dynamic> json) {
    return ArtistAnnouncement(
      service: (json['service'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      hash: json['hash']?.toString(),
      added: json['added'] != null
          ? DateTime.tryParse(json['added'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'service': service,
        'user_id': userId,
        'content': content,
        if (hash != null) 'hash': hash,
        if (added != null) 'added': added?.toIso8601String(),
      };
}
