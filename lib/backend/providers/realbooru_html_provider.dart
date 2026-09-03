import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../models/post.dart';
import '../models/provider_health.dart';
import '../models/tag_suggestion.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class RealbooruHtmlProvider
    implements
        ContentProvider,
        PostPageProvider,
        MediaHeadersProvider,
        TagSuggestionProvider {
  RealbooruHtmlProvider({
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
    final queryTags = [
      if (tags.isEmpty) 'all' else ...tags,
      if (rating != null && rating.isNotEmpty) 'rating:$rating',
    ].join(' ');
    final response = await _dio.get<String>(
      '/index.php',
      queryParameters: {
        'page': 'post',
        's': 'list',
        'tags': queryTags,
        'pid': page * limit,
      },
      options: Options(responseType: ResponseType.plain),
    );
    return _parseList(response.data ?? '').take(limit).toList(growable: false);
  }

  @override
  Future<Post?> getPost(String id) async {
    final response = await _dio.get<String>(
      '/index.php',
      queryParameters: {'page': 'post', 's': 'view', 'id': id},
      options: Options(responseType: ResponseType.plain),
    );
    return _parseDetails(id, response.data ?? '');
  }

  @override
  Future<ProviderHealth> checkHealth() async {
    final startedAt = DateTime.now();
    try {
      final posts = await searchPosts(tags: const ['all'], page: 0, limit: 1);
      return ProviderHealth(
        providerId: id,
        status: posts.isEmpty ? ProviderStatus.offline : ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: 'realbooru-html',
        errorMessage: posts.isEmpty ? 'No posts found in HTML response' : null,
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
      );
    }
  }

  @override
  String postPageUrl(Post post) =>
      '$baseUrl/index.php?page=post&s=view&id=${post.id}';

  @override
  Map<String, String> mediaHeaders(Post post) => {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/125 Mobile Safari/537.36',
        'Accept':
            'video/webm,video/mp4,image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
        'Referer': postPageUrl(post),
      };

  @override
  Future<List<TagSuggestion>> suggestTags(String query,
      {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final response = await _dio.get<dynamic>(
      '/index.php',
      queryParameters: {
        'page': 'autocomplete',
        'term': trimmed,
      },
    );
    final values = _autocompleteItems(response.data);
    return values
        .map((name) => TagSuggestion(
              name: name,
              category: TagCategory.unknown,
              postCount: 0,
              providerId: id,
            ))
        .where((item) => item.name.toLowerCase().startsWith(
              trimmed.toLowerCase(),
            ))
        .take(limit.clamp(1, 50))
        .toList(growable: false);
  }

  List<Post> _parseList(String html) {
    final posts = <Post>[];
    final pattern = RegExp(
      r'''<div[^>]*class=["'][^"']*\bthumb\b[^"']*["'][^>]*id=["']s(\d+)["'][\s\S]*?<a[^>]+href=["']([^"']*page=post[^"']*s=view[^"']*id=\d+[^"']*)["'][\s\S]*?<img[^>]+src=["']([^"']+)["'][^>]*>''',
      caseSensitive: false,
    );
    for (final match in pattern.allMatches(html)) {
      final id = match.group(1) ?? '';
      final imgTag = match.group(0) ?? '';
      final previewUrl = _absolute(_decode(match.group(3) ?? ''));
      final tags = _tags(_attribute(imgTag, 'title'));
      final isVideo = imgTag.contains('#0000ff') ||
          tags.contains('webm') ||
          tags.contains('video');
      final isGif =
          !isVideo && (tags.contains('gif') || tags.contains('animated_gif'));
      final derivedOriginal =
          isVideo ? '' : _imageUrlFromThumbnail(previewUrl, gif: isGif);
      posts.add(
        Post(
          id: id,
          providerId: this.id,
          providerName: name,
          previewUrl: previewUrl,
          sampleUrl: derivedOriginal.isEmpty ? previewUrl : derivedOriginal,
          fileUrl: isVideo ? '' : derivedOriginal,
          tags: tags,
          rating: 'explicit',
          width: 0,
          height: 0,
          source: postPageUrl(Post(
            id: id,
            providerId: this.id,
            providerName: name,
            previewUrl: previewUrl,
            sampleUrl: derivedOriginal.isEmpty ? previewUrl : derivedOriginal,
            fileUrl: isVideo ? '' : derivedOriginal,
            tags: tags,
            rating: 'explicit',
            width: 0,
            height: 0,
            createdAt: DateTime.now(),
            fileType: isVideo
                ? 'video'
                : isGif
                    ? 'gif'
                    : 'image',
            score: 0,
          )),
          createdAt: DateTime.now(),
          fileType: isVideo
              ? 'video'
              : isGif
                  ? 'gif'
                  : 'image',
          score: 0,
          tagGroups: _tagGroups(tags),
        ),
      );
    }
    return posts;
  }

  Post? _parseDetails(String postId, String html) {
    final imageTag = RegExp(
      r'''<(?:img|video)[^>]+(?:id=["']image["'][^>]*|[^>]*id=["']image["'])''',
      caseSensitive: false,
    ).firstMatch(html)?.group(0);
    final originalUrl = _absolute(
      RegExp(
            r'''<a[^>]+href=["']([^"']+)["'][^>]*>\s*Original\s*</a>''',
            caseSensitive: false,
          ).firstMatch(html)?.group(1) ??
          '',
    );
    final videoSources = RegExp(
      r'''<source[^>]+src=["']([^"']+\.(?:webm|mp4)[^"']*)["']''',
      caseSensitive: false,
    )
        .allMatches(html)
        .map((match) => _absolute(match.group(1) ?? ''))
        .where((url) => url.isNotEmpty)
        .toList();
    videoSources.sort((left, right) {
      final leftWebm = left.toLowerCase().split('?').first.endsWith('.webm');
      final rightWebm = right.toLowerCase().split('?').first.endsWith('.webm');
      if (leftWebm == rightWebm) return 0;
      return leftWebm ? -1 : 1;
    });
    final imageUrl = _absolute(_attribute(imageTag ?? '', 'src'));
    final mediaUrl = videoSources.isNotEmpty
        ? videoSources.first
        : originalUrl.isNotEmpty
            ? originalUrl
            : imageUrl;
    final sampleUrl = videoSources.length > 1 ? videoSources[1] : mediaUrl;
    final source = _attribute(
      RegExp(r'''<input[^>]+id=["']source["'][^>]*>''', caseSensitive: false)
              .firstMatch(html)
              ?.group(0) ??
          '',
      'value',
    );
    final tagsText = _attribute(imageTag ?? '', 'alt').isNotEmpty
        ? _attribute(imageTag ?? '', 'alt')
        : RegExp(
              r'''<textarea[^>]+id=["']tags["'][^>]*>([\s\S]*?)</textarea>''',
              caseSensitive: false,
            ).firstMatch(html)?.group(1) ??
            '';
    final tags = _tags(tagsText);
    if (mediaUrl.isEmpty) return null;
    return Post(
      id: postId,
      providerId: id,
      providerName: name,
      previewUrl: imageUrl.isEmpty ? mediaUrl : imageUrl,
      sampleUrl: sampleUrl,
      fileUrl: mediaUrl,
      tags: tags,
      rating: 'explicit',
      width: 0,
      height: 0,
      source: source.isEmpty ? postPageUrlById(postId) : source,
      createdAt: DateTime.now(),
      fileType: _fileType(mediaUrl),
      score: 0,
      tagGroups: _tagGroups(tags),
    );
  }

  String postPageUrlById(String postId) =>
      '$baseUrl/index.php?page=post&s=view&id=$postId';

  String _attribute(String source, String name) {
    final match = RegExp(
      '''$name\\s*=\\s*["']([^"']*)["']''',
      caseSensitive: false,
    ).firstMatch(source);
    return _decode(match?.group(1) ?? '');
  }

  List<String> _tags(String value) {
    return _decode(value)
        .replaceAll(',', ' ')
        .split(RegExp(r'\s+'))
        .map((tag) => tag.trim().replaceAll(' ', '_'))
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  Map<String, List<String>> _tagGroups(List<String> tags) =>
      tags.isEmpty ? const {} : {'general': tags};

  String _fileType(String url) {
    final lower = url.toLowerCase().split('?').first;
    if (lower.endsWith('.webm') || lower.endsWith('.mp4')) return 'video';
    if (lower.endsWith('.gif')) return 'gif';
    return 'image';
  }

  String _absolute(String url) {
    final value = _decode(url.trim());
    if (value.startsWith('//')) return _normalizeUrl('https:$value');
    if (value.startsWith('/')) return _normalizeUrl('$baseUrl$value');
    return _normalizeUrl(value);
  }

  String _normalizeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return url;
    final normalizedPath = uri.path.replaceFirst(RegExp(r'^/+'), '/');
    return uri.replace(path: normalizedPath).toString();
  }

  String _imageUrlFromThumbnail(String thumbnailUrl, {bool gif = false}) {
    final uri = Uri.tryParse(thumbnailUrl);
    if (uri == null) return '';
    final match = RegExp(r'/thumbnails/([^/]+)/([^/]+)/thumbnail_([^/.]+)\.')
        .firstMatch(uri.path);
    if (match == null) return '';
    final extension = gif ? 'gif' : 'jpeg';
    final path =
        '/images/${match.group(1)}/${match.group(2)}/${match.group(3)}.$extension';
    return uri.replace(path: path, query: '').toString();
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

  List<String> _autocompleteItems(dynamic data) {
    final source = data is String ? jsonDecode(data) : data;
    if (source is List) {
      return source
          .map((item) => item.toString().trim().replaceAll(' ', '_'))
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(growable: false);
    }
    return const [];
  }
}
