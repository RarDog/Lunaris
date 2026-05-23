enum ProviderStatus { unknown, online, offline }

class ProviderHealth {
  const ProviderHealth({
    required this.providerId,
    required this.status,
    required this.pingMs,
    required this.lastCheckedAt,
    this.errorMessage,
    this.apiVersion,
  });

  final String providerId;
  final ProviderStatus status;
  final int pingMs;
  final DateTime lastCheckedAt;
  final String? errorMessage;
  final String? apiVersion;

  bool get isOnline => status == ProviderStatus.online;

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'status': status.name,
        'pingMs': pingMs,
        'lastCheckedAt': lastCheckedAt.toIso8601String(),
        'errorMessage': errorMessage,
        'apiVersion': apiVersion,
      };

  factory ProviderHealth.fromJson(Map<String, dynamic> json) => ProviderHealth(
        providerId: json['providerId'] as String,
        status: ProviderStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => ProviderStatus.unknown,
        ),
        pingMs: (json['pingMs'] as num?)?.toInt() ?? 0,
        lastCheckedAt: DateTime.parse(json['lastCheckedAt'] as String),
        errorMessage: json['errorMessage'] as String?,
        apiVersion: json['apiVersion'] as String?,
      );
}
