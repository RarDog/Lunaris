import '../models/post.dart';

class DanbooruMapper {
  static List<Post> postsFromResponse(
    dynamic data, {
    required String providerId,
    required String providerName,
  }) {
    final items = data is List ? data : const [];
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
    final fileUrl = _string(json['file_url'] ?? json['large_file_url']);
    final sampleUrl =
        _string(json['large_file_url'] ?? json['sample_file_url'] ?? fileUrl);
    final previewUrl = _string(json['preview_file_url'] ?? sampleUrl);
    return Post(
      id: _string(json['id']),
      providerId: providerId,
      providerName: providerName,
      previewUrl: previewUrl,
      sampleUrl: sampleUrl,
      fileUrl: fileUrl,
      tags: _tags(json['tag_string'] ?? json['tags']),
      rating: _string(json['rating'], fallback: 'unknown'),
      width: _int(json['image_width'] ?? json['width']),
      height: _int(json['image_height'] ?? json['height']),
      source: _nullableString(json['source']),
      createdAt:
          DateTime.tryParse(_string(json['created_at'])) ?? DateTime.now(),
      fileType: _fileType(fileUrl),
      score: _int(json['score']),
    );
  }

  static List<String> _tags(dynamic value) {
    if (value is List) return value.map((tag) => tag.toString()).toList();
    return _string(value)
        .split(RegExp(r'\s+'))
        .where((tag) => tag.trim().isNotEmpty)
        .toSet()
        .toList();
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

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static String _fileType(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.webm') || lower.endsWith('.mp4')) return 'video';
    if (lower.endsWith('.gif')) return 'gif';
    if (lower.isEmpty) return 'unknown';
    return 'image';
  }
}
