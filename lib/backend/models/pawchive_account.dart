class PawchiveAccount {
  const PawchiveAccount({
    required this.id,
    required this.username,
    required this.sessionCookie,
    this.baseUrl = 'https://pawchive.pw',
    required this.createdAt,
    this.lastSyncedAt,
    this.isActive = true,
    this.syncedArtistsCount = 0,
  });

  final String id;
  final String username;
  final String sessionCookie;
  final String baseUrl;
  final DateTime createdAt;
  final DateTime? lastSyncedAt;
  final bool isActive;
  final int syncedArtistsCount;

  PawchiveAccount copyWith({
    String? id,
    String? username,
    String? sessionCookie,
    String? baseUrl,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    bool? isActive,
    int? syncedArtistsCount,
  }) {
    return PawchiveAccount(
      id: id ?? this.id,
      username: username ?? this.username,
      sessionCookie: sessionCookie ?? this.sessionCookie,
      baseUrl: baseUrl ?? this.baseUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isActive: isActive ?? this.isActive,
      syncedArtistsCount: syncedArtistsCount ?? this.syncedArtistsCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'sessionCookie': sessionCookie,
        'baseUrl': baseUrl,
        'createdAt': createdAt.toIso8601String(),
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'isActive': isActive,
        'syncedArtistsCount': syncedArtistsCount,
      };

  factory PawchiveAccount.fromJson(Map<String, dynamic> json) {
    return PawchiveAccount(
      id: (json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      sessionCookie: (json['sessionCookie'] ?? '').toString(),
      baseUrl: (json['baseUrl'] ?? 'https://pawchive.pw').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'].toString())
          : null,
      isActive: json['isActive'] as bool? ?? true,
      syncedArtistsCount: (json['syncedArtistsCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PawchiveAccount &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
