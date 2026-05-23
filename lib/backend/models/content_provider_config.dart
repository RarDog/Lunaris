class ContentProviderConfig {
  const ContentProviderConfig({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiType,
    required this.enabled,
    required this.priority,
    required this.timeoutSeconds,
    required this.customHeaders,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String baseUrl;
  final String apiType;
  final bool enabled;
  final int priority;
  final int timeoutSeconds;
  final Map<String, String> customHeaders;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentProviderConfig copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? apiType,
    bool? enabled,
    int? priority,
    int? timeoutSeconds,
    Map<String, String>? customHeaders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentProviderConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiType: apiType ?? this.apiType,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      customHeaders: customHeaders ?? this.customHeaders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseUrl': baseUrl,
        'apiType': apiType,
        'enabled': enabled,
        'priority': priority,
        'timeoutSeconds': timeoutSeconds,
        'customHeaders': customHeaders,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ContentProviderConfig.fromJson(Map<String, dynamic> json) {
    return ContentProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      apiType: json['apiType'] as String,
      enabled: (json['enabled'] as bool?) ?? true,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 20,
      customHeaders: Map<String, String>.from(
        (json['customHeaders'] as Map?) ?? const {},
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
