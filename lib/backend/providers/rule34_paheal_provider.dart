import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../models/post.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class Rule34PahealProvider implements ContentProvider, PostPageProvider {
  Rule34PahealProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required DioClient dioClient,
  }) : _dio = dioClient.dio;

  @override
  final String id;
  @override
  final String name;
  @override
  final String baseUrl;
  final Dio _dio;

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    // Paheal's public HTML list ignores common sort/top query parameters and
    // exposes no stable top-period endpoint, so non-latest filters fall back
    // to the regular list instead of pretending to support ranking.
    final query = tags
        .where((tag) => tag.trim().isNotEmpty && tag.trim() != 'all')
        .map((tag) => tag.trim().replaceAll(' ', '_'))
        .join('_');
    final path = query.isEmpty
        ? '/post/list/${page + 1}'
        : '/post/list/$query/${page + 1}';
    final response = await _dio.get<String>(
      path,
      options: Options(responseType: ResponseType.plain),
    );
    return _parseList(response.data ?? '').take(limit).toList(growable: false);
  }

  @override
  Future<Post?> getPost(String id) async {
    final response = await _dio.get<String>(
      '/post/view/$id',
      options: Options(responseType: ResponseType.plain),
    );
    return _parseSingle(id, response.data ?? '');
  }

  @override
  Future<ProviderHealth> checkHealth() async {
    final startedAt = DateTime.now();
    try {
      final posts = await searchPosts(tags: const [], page: 0, limit: 1);
      return ProviderHealth(
        providerId: id,
        status: posts.isEmpty ? ProviderStatus.offline : ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: 'paheal-html',
        errorMessage: posts.isEmpty ? 'No posts found in HTML response' : null,
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
        apiVersion: 'paheal-html',
      );
    }
  }

  @override
  String postPageUrl(Post post) => '$baseUrl/post/view/${post.id}';

  List<Post> _parseList(String html) {
    final posts = <Post>[];
    final pattern = RegExp(
      r'''<div[^>]+class=['"][^'"]*\bshm-thumb\b[^'"]*['"][\s\S]*?</div>''',
      caseSensitive: false,
    );
    for (final match in pattern.allMatches(html)) {
      final block = match.group(0) ?? '';
      final postId = _attribute(block, 'data-post-id');
      final fileUrl = _absolute(
        RegExp(
              r'''<a[^>]+href=['"]([^'"]+)['"][^>]*>\s*File Only\s*</a>''',
              caseSensitive: false,
            ).firstMatch(block)?.group(1) ??
            '',
      );
      final previewUrl = _absolute(
        RegExp(r'''<img[^>]+src=['"]([^'"]+)['"]''', caseSensitive: false)
                .firstMatch(block)
                ?.group(1) ??
            '',
      );
      if (postId.isEmpty || (fileUrl.isEmpty && previewUrl.isEmpty)) continue;
      final tags = _tags(_attribute(block, 'data-tags'));
      final ext = _attribute(block, 'data-ext');
      final dimensions = _dimensions(_attribute(block, 'title'));
      final mediaUrl = fileUrl.isEmpty ? previewUrl : fileUrl;
      posts.add(
        Post(
          id: postId,
          providerId: id,
          providerName: name,
          previewUrl: previewUrl.isEmpty ? mediaUrl : previewUrl,
          sampleUrl: mediaUrl,
          fileUrl: mediaUrl,
          tags: tags,
          rating: 'explicit',
          width: dimensions.$1,
          height: dimensions.$2,
          source: '$baseUrl/post/view/$postId',
          createdAt: DateTime.now(),
          fileType: _fileType('$ext $mediaUrl'),
          score: 0,
          tagGroups: tags.isEmpty ? const {} : {'general': tags},
        ),
      );
    }
    if (posts.isNotEmpty) return posts;
    final singleId = RegExp(r'''/post/view/(\d+)''').firstMatch(html)?.group(1);
    final single = singleId == null ? null : _parseSingle(singleId, html);
    return single == null ? const [] : [single];
  }

  Post? _parseSingle(String postId, String html) {
    final fileUrl = _absolute(
      RegExp(
            r'''<a[^>]+href=['"]([^'"]+)['"][^>]*>\s*(?:File|Image) Only\s*</a>''',
            caseSensitive: false,
          ).firstMatch(html)?.group(1) ??
          RegExp(
            r'''<(?:img|video|source)[^>]+src=['"]([^'"]+(?:jpg|jpeg|png|gif|webm|mp4)[^'"]*)['"]''',
            caseSensitive: false,
          ).firstMatch(html)?.group(1) ??
          '',
    );
    final previewUrl = _absolute(
      RegExp(
            r'''<meta[^>]+property=['"]og:image['"][^>]+content=['"]([^'"]+)['"]''',
            caseSensitive: false,
          ).firstMatch(html)?.group(1) ??
          '',
    );
    final tagsText = RegExp(
          r'''<meta[^>]+name=['"]keywords['"][^>]+content=['"]([^'"]+)['"]''',
          caseSensitive: false,
        ).firstMatch(html)?.group(1) ??
        '';
    final mediaUrl = fileUrl.isEmpty ? previewUrl : fileUrl;
    if (mediaUrl.isEmpty) return null;
    final tags = _tags(tagsText);
    return Post(
      id: postId,
      providerId: id,
      providerName: name,
      previewUrl: previewUrl.isEmpty ? mediaUrl : previewUrl,
      sampleUrl: mediaUrl,
      fileUrl: mediaUrl,
      tags: tags,
      rating: 'explicit',
      width: 0,
      height: 0,
      source: '$baseUrl/post/view/$postId',
      createdAt: DateTime.now(),
      fileType: _fileType(mediaUrl),
      score: 0,
      tagGroups: tags.isEmpty ? const {} : {'general': tags},
    );
  }

  String _attribute(String source, String name) {
    return _decode(
      RegExp(
            '''$name\\s*=\\s*['"]([^'"]*)['"]''',
            caseSensitive: false,
          ).firstMatch(source)?.group(1) ??
          '',
    );
  }

  (int, int) _dimensions(String value) {
    final match = RegExp(r'(\d+)x(\d+)').firstMatch(value);
    return (
      int.tryParse(match?.group(1) ?? '') ?? 0,
      int.tryParse(match?.group(2) ?? '') ?? 0,
    );
  }

  List<String> _tags(String value) {
    return _decode(value)
        .replaceAll(',', ' ')
        .split(RegExp(r'\s+'))
        .map((tag) => tag.trim().replaceAll(' ', '_').toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  String _fileType(String value) {
    final lower = value.toLowerCase().split('?').first;
    if (lower.contains('webm') || lower.contains('mp4')) return 'video';
    if (lower.contains('gif')) return 'gif';
    if (lower.contains('png')) return 'png';
    return 'image';
  }

  String _absolute(String url) {
    final value = _decode(url.trim());
    if (value.isEmpty) return '';
    if (value.startsWith('//')) return 'https:$value';
    if (value.startsWith('/')) return '$baseUrl$value';
    return value;
  }

  String _decode(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'");
  }
}
