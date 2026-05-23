import '../models/post.dart';

class GelbooruMapper {
  static List<Post> postsFromResponse(
    dynamic data, {
    required String providerId,
    required String providerName,
  }) {
    final items = _extractItems(data);
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
    final id = _string(json['id']);
    final fileUrl = _string(json['file_url'] ?? json['fileUrl']);
    final sampleUrl = _string(json['sample_url'] ??
        json['sampleUrl'] ??
        json['large_file_url'] ??
        fileUrl);
    final previewUrl =
        _string(json['preview_url'] ?? json['previewUrl'] ?? sampleUrl);
    return Post(
      id: id,
      providerId: providerId,
      providerName: providerName,
      previewUrl: previewUrl,
      sampleUrl: sampleUrl,
      fileUrl: fileUrl,
      tags: _tags(json['tags'] ?? json['tag_string']),
      rating: _string(json['rating'], fallback: 'unknown'),
      width: _int(json['width']),
      height: _int(json['height']),
      source: _nullableString(json['source']),
      createdAt: _date(json['created_at'] ?? json['createdAt']),
      fileType: _fileType(fileUrl),
      score: _int(json['score']),
    );
  }

  static List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final posts = data['post'] ?? data['posts'];
      if (posts is List) return posts;
      if (posts is Map && posts['post'] is List) return posts['post'] as List;
      if (posts is Map) return [posts];
    }
    return const [];
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

  static DateTime _date(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static String _fileType(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.webm') || lower.endsWith('.mp4')) return 'video';
    if (lower.endsWith('.gif')) return 'gif';
    if (lower.isEmpty) return 'unknown';
    return 'image';
  }
}
