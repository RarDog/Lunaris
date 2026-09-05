import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../mappers/e621_mapper.dart';
import '../models/e621_pool.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/tag_suggestion.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class E621Provider
    implements
        ContentProvider,
        TagSuggestionProvider,
        CommentProvider,
        PostPageProvider {
  E621Provider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required DioClient dioClient,
    Map<String, String> queryParameters = const {},
  })  : _dio = dioClient.dio,
        _queryParameters = queryParameters;

  @override
  final String id;
  @override
  final String name;
  @override
  final String baseUrl;
  final Dio _dio;
  final Map<String, String> _queryParameters;

  static DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);

  static Future<void> _throttle() async {
    final now = DateTime.now();
    final diff = now.difference(_lastRequestTime);
    if (diff.inMilliseconds < 500) {
      final waitMs = 500 - diff.inMilliseconds;
      await Future<void>.delayed(Duration(milliseconds: waitMs));
    }
    _lastRequestTime = DateTime.now();
  }

  bool get isAuthorized =>
      _queryParameters.containsKey('login') ||
      _dio.options.headers.containsKey('Authorization');

  String? get login => _queryParameters['login'];

  @override
  String postPageUrl(Post post) => '$baseUrl/posts/${post.id}';

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    await _throttle();
    final response = await _dio.get<dynamic>(
      '/posts.json',
      queryParameters: {
        'page': page + 1,
        'limit': limit.clamp(1, 75),
        'tags': [
          ...tags,
          if (rating != null && rating.isNotEmpty) 'rating:${_rating(rating)}',
          ..._topTags(topPeriod),
        ].join(' '),
        ..._queryParameters,
      },
    );
    return E621Mapper.postsFromResponse(
      response.data,
      providerId: id,
      providerName: name,
    );
  }

  @override
  Future<Post?> getPost(String id) async {
    await _throttle();
    final response = await _dio.get<dynamic>(
      '/posts/$id.json',
      queryParameters: _queryParameters,
    );
    final posts = E621Mapper.postsFromResponse(
      response.data,
      providerId: this.id,
      providerName: name,
    );
    return posts.isEmpty ? null : posts.first;
  }

  Future<E621Pool?> getPool(String poolId) async {
    await _throttle();
    try {
      final response = await _dio.get<dynamic>(
        '/pools/$poolId.json',
        queryParameters: _queryParameters,
      );
      if (response.data is Map) {
        return E621Pool.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (_) {}
    return null;
  }

  Future<bool> votePost(String postId, int score) async {
    await _throttle();
    try {
      final response = await _dio.post<dynamic>(
        '/posts/$postId/votes.json',
        data: {'score': score, 'no_unvote': 'true'},
        queryParameters: _queryParameters,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addFavorite(String postId) async {
    await _throttle();
    try {
      final response = await _dio.post<dynamic>(
        '/favorites.json',
        data: {'post_id': postId},
        queryParameters: _queryParameters,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeFavorite(String postId) async {
    await _throttle();
    try {
      final response = await _dio.delete<dynamic>(
        '/favorites/$postId.json',
        queryParameters: _queryParameters,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProviderHealth> checkHealth() async {
    final startedAt = DateTime.now();
    try {
      await _dio.get<dynamic>(
        '/posts.json',
        queryParameters: {'limit': 1, ..._queryParameters},
      );
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: 'e621',
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
        apiVersion: 'e621',
      );
    }
  }

  @override
  Future<List<TagSuggestion>> suggestTags(String query,
      {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];
    await _throttle();
    final response = await _dio.get<dynamic>(
      '/tags.json',
      queryParameters: {
        'search[name_matches]': '${query.trim()}*',
        'search[order]': 'count',
        'limit': limit.clamp(1, 50),
        ..._queryParameters,
      },
    );
    final items = response.data is List ? response.data as List : const [];
    return items
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          return TagSuggestion(
            name: (json['name'] ?? '').toString(),
            category: tagCategoryFromString(json['category']?.toString()),
            postCount: _int(json['post_count']),
            providerId: id,
          );
        })
        .where((tag) => tag.name.isNotEmpty)
        .toList();
  }

  @override
  Future<List<PostComment>> getComments(String postId) async {
    await _throttle();
    final response = await _dio.get<dynamic>(
      '/comments.json',
      queryParameters: {
        'search[post_id]': postId,
        'limit': 50,
        ..._queryParameters,
      },
    );
    final items = response.data is List ? response.data as List : const [];
    return items
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          return PostComment(
            id: (json['id'] ?? '').toString(),
            postId: (json['post_id'] ?? postId).toString(),
            providerId: id,
            authorName: (json['creator_name'] ?? json['creator_id'] ?? 'user')
                .toString(),
            body: (json['body'] ?? '').toString(),
            createdAt:
                DateTime.tryParse((json['created_at'] ?? '').toString()) ??
                    DateTime.fromMillisecondsSinceEpoch(0),
          );
        })
        .where((comment) => comment.body.trim().isNotEmpty)
        .toList();
  }

  String _rating(String value) {
    return switch (value.toLowerCase()) {
      'safe' => 's',
      'questionable' => 'q',
      'explicit' => 'e',
      _ => value,
    };
  }

  List<String> _topTags(TopPeriodFilter period) {
    final now = DateTime.now();
    return switch (period) {
      TopPeriodFilter.none => const [],
      TopPeriodFilter.month => [
          'order:score',
          'date:>${_date(now.subtract(const Duration(days: 31)))}',
        ],
      TopPeriodFilter.year => [
          'order:score',
          'date:>${_date(DateTime(now.year - 1, now.month, now.day))}',
        ],
      TopPeriodFilter.allTime => const ['order:score'],
    };
  }

  String _date(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
