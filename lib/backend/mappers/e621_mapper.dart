import '../models/post.dart';

class E621Mapper {
  static List<Post> postsFromResponse(
    dynamic data, {
    required String providerId,
    required String providerName,
  }) {
    final posts = data is Map ? data['posts'] : data;
    final items = posts is List ? posts : const [];
    return items
        .whereType<Map>()
        .map((item) => postFromJson(
              Map<String, dynamic>.from(item),
              providerId: providerId,
              providerName: providerName,
            ))
        .toList();
  }

  static Post postFromJson(
    Map<String, dynamic> json, {
    required String providerId,
    required String providerName,
  }) {
    final file = Map<String, dynamic>.from((json['file'] as Map?) ?? const {});
    final preview =
        Map<String, dynamic>.from((json['preview'] as Map?) ?? const {});
    final sample =
        Map<String, dynamic>.from((json['sample'] as Map?) ?? const {});
    final score =
        Map<String, dynamic>.from((json['score'] as Map?) ?? const {});
    final tagsMap =
        Map<String, dynamic>.from((json['tags'] as Map?) ?? const {});
    final tagGroups = {
      for (final entry in tagsMap.entries)
        entry.key: List<String>.from((entry.value as List?) ?? const []),
    }..removeWhere((_, value) => value.isEmpty);
    final tags = tagGroups.values.expand((items) => items).toSet().toList();
    final fileUrl = _string(file['url']);
    return Post(
      id: _string(json['id']),
      providerId: providerId,
      providerName: providerName,
      previewUrl: _string(preview['url'] ?? sample['url'] ?? fileUrl),
      sampleUrl: _string(sample['url'] ?? fileUrl),
      fileUrl: fileUrl,
      tags: tags,
      rating: _rating(_string(json['rating'], fallback: 'unknown')),
      width: _int(file['width']),
      height: _int(file['height']),
      source: _sources(json['sources']),
      createdAt:
          DateTime.tryParse(_string(json['created_at'])) ?? DateTime.now(),
      fileType: _fileType(fileUrl, file['ext']),
      score: _int(score['total'] ?? json['score']),
      tagGroups: tagGroups,
    );
  }

  static String _rating(String value) {
    return switch (value.toLowerCase()) {
      's' => 'safe',
      'q' => 'questionable',
      'e' => 'explicit',
      _ => value,
    };
  }

  static String? _sources(dynamic value) {
    if (value is List && value.isNotEmpty) return value.first.toString();
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String _fileType(String url, dynamic fileExt) {
    final lower = url.toLowerCase().split('?').first;
    final ext = _string(fileExt).toLowerCase();
    if (lower.endsWith('.webm') ||
        lower.endsWith('.mp4') ||
        ext == 'webm' ||
        ext == 'mp4') {
      return 'video';
    }
    if (lower.endsWith('.gif') || ext == 'gif') return 'gif';
    if (lower.isEmpty) return 'unknown';
    return 'image';
  }
}
