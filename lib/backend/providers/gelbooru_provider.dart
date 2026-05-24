import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/http/dio_client.dart';
import '../mappers/gelbooru_mapper.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class GelbooruProvider implements ContentProvider, CommentProvider {
  GelbooruProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required DioClient dioClient,
    Map<String, String> queryParameters = const {},
  })  : _queryParameters = queryParameters,
        _dio = dioClient.dio;

  @override
  final String id;
  @override
  final String name;
  @override
  final String baseUrl;
  final Dio _dio;
  final Map<String, String> _queryParameters;
  Dio get dio => _dio;
  Map<String, String> get queryParameters => _queryParameters;

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    final queryTags = [
      ...tags,
      if (rating != null && rating.isNotEmpty) 'rating:$rating',
      ..._topTags(topPeriod),
    ];
    final response = await _dio.get<dynamic>(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'post',
        'q': 'index',
        'json': '1',
        'pid': page,
        'limit': limit,
        'tags': queryTags.join(' '),
        ..._queryParameters,
      },
    );
    return GelbooruMapper.postsFromResponse(
      response.data,
      providerId: id,
      providerName: name,
    );
  }

  @override
  Future<Post?> getPost(String id) async {
    final response = await _dio.get<dynamic>(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'post',
        'q': 'index',
        'json': '1',
        'id': id,
        ..._queryParameters,
      },
    );
    final posts = GelbooruMapper.postsFromResponse(
      response.data,
      providerId: this.id,
      providerName: name,
    );
    return posts.isEmpty ? null : posts.first;
  }

  @override
  Future<ProviderHealth> checkHealth() async {
    final startedAt = DateTime.now();
    try {
      await _dio.get<dynamic>(
        '/index.php',
        queryParameters: {
          'page': 'dapi',
          's': 'post',
          'q': 'index',
          'json': '1',
          'limit': 1,
          ..._queryParameters,
        },
      );
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: 'gelbooru-compatible',
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
        apiVersion: 'gelbooru-compatible',
      );
    }
  }

  @override
  Future<List<PostComment>> getComments(String postId) async {
    final response = await _dio.get<dynamic>(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'comment',
        'q': 'index',
        'json': '1',
        'post_id': postId,
        ..._queryParameters,
      },
    );
    return _commentsFromResponse(response.data, postId);
  }

  Never unavailable(String message) =>
      throw ProviderUnavailableException(message);

  List<String> _topTags(TopPeriodFilter period) {
    return switch (period) {
      TopPeriodFilter.none => const [],
      TopPeriodFilter.month ||
      TopPeriodFilter.year ||
      TopPeriodFilter.allTime =>
        const ['sort:score:desc'],
    };
  }

  List<PostComment> _commentsFromResponse(dynamic data, String postId) {
    final raw = _commentItems(data);
    return raw
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          return PostComment(
            id: (json['id'] ?? json['comment_id'] ?? '').toString(),
            postId: (json['post_id'] ?? postId).toString(),
            providerId: id,
            authorName: (json['creator'] ??
                    json['creator_name'] ??
                    json['creator_id'] ??
                    json['user'] ??
                    json['username'] ??
                    json['author'] ??
                    '')
                .toString(),
            body: (json['body'] ??
                    json['comment'] ??
                    json['content'] ??
                    json['text'] ??
                    '')
                .toString(),
            createdAt: DateTime.tryParse(
                  (json['created_at'] ?? json['created'] ?? '').toString(),
                ) ??
                DateTime.fromMillisecondsSinceEpoch(0),
          );
        })
        .where((comment) => comment.body.trim().isNotEmpty)
        .toList();
  }

  List<dynamic> _commentItems(dynamic data) {
    if (data is List) return data;
    if (data is String) return _commentItemsFromText(data);
    if (data is! Map) return const [];
    final json = Map<String, dynamic>.from(data);
    final comments = json['comments'];
    if (comments is List) return comments;
    if (comments is Map) return _commentItems(comments);
    final comment = json['comment'];
    if (comment is List) return comment;
    if (comment is Map) return [comment];
    return const [];
  }

  List<Map<String, dynamic>> _commentItemsFromText(String text) {
    final items = <Map<String, dynamic>>[];
    for (final match in RegExp(r'<comment\b([^>]*)>(.*?)</comment>',
            caseSensitive: false, dotAll: true)
        .allMatches(text)) {
      final attrs = _attributes(match.group(1) ?? '');
      final body = _tagValue(match.group(2) ?? '', 'body') ??
          _tagValue(match.group(2) ?? '', 'comment') ??
          match.group(2) ??
          '';
      items.add({...attrs, 'body': body});
    }
    for (final match
        in RegExp(r'<comment\b([^>]*)/?>', caseSensitive: false, dotAll: true)
            .allMatches(text)) {
      final attrs = _attributes(match.group(1) ?? '');
      if (attrs.isNotEmpty) items.add(attrs);
    }
    return items;
  }

  Map<String, dynamic> _attributes(String source) {
    final result = <String, dynamic>{};
    for (final match in RegExp(r'''([A-Za-z0-9_:-]+)\s*=\s*["']([^"']*)["']''')
        .allMatches(source)) {
      result[match.group(1)!] = _decodeEntities(match.group(2) ?? '');
    }
    return result;
  }

  String? _tagValue(String source, String tag) {
    final match =
        RegExp('<$tag[^>]*>(.*?)</$tag>', caseSensitive: false, dotAll: true)
            .firstMatch(source);
    final value = match?.group(1);
    return value == null ? null : _decodeEntities(value.trim());
  }

  String _decodeEntities(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'");
  }
}
