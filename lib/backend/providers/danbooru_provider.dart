import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../mappers/danbooru_mapper.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/tag_suggestion.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class DanbooruProvider
    implements
        ContentProvider,
        CommentProvider,
        PostPageProvider,
        TagSuggestionProvider {
  DanbooruProvider({
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
    final queryTags = [
      ...tags,
      if (rating != null && rating.isNotEmpty) 'rating:$rating',
      ..._topTags(topPeriod),
    ];
    final response = await _dio.get<dynamic>(
      '/posts.json',
      queryParameters: {
        'page': page + 1,
        'limit': limit,
        'tags': queryTags.join(' '),
        ..._queryParameters,
      },
    );
    return DanbooruMapper.postsFromResponse(
      response.data,
      providerId: id,
      providerName: name,
    );
  }

  @override
  Future<Post?> getPost(String id) async {
    final response = await _dio.get<dynamic>(
      '/posts/$id.json',
      queryParameters: _queryParameters,
    );
    final posts = DanbooruMapper.postsFromResponse(
      [response.data],
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
        '/posts.json',
        queryParameters: {'limit': 1, ..._queryParameters},
      );
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: 'danbooru',
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
        apiVersion: 'danbooru',
      );
    }
  }

  @override
  Future<List<PostComment>> getComments(String postId) async {
    final response = await _dio.get<dynamic>(
      '/comments.json',
      queryParameters: {
        'search[post_id]': postId,
        'limit': 50,
        ..._queryParameters,
      },
    );
    final items = _commentItems(response.data);
    return items
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          return PostComment(
            id: (json['id'] ?? '').toString(),
            postId: (json['post_id'] ?? postId).toString(),
            providerId: id,
            authorName: (json['creator_name'] ??
                    json['creator_id'] ??
                    json['updater_name'] ??
                    'user')
                .toString(),
            body: (json['body'] ?? json['text'] ?? json['comment'] ?? '')
                .toString(),
            createdAt:
                DateTime.tryParse((json['created_at'] ?? '').toString()) ??
                    DateTime.fromMillisecondsSinceEpoch(0),
          );
        })
        .where((comment) => comment.body.trim().isNotEmpty)
        .toList();
  }

  List<dynamic> _commentItems(dynamic data) {
    if (data is List) return data;
    if (data is! Map) return const [];
    final json = Map<String, dynamic>.from(data);
    final comments = json['comments'];
    if (comments is List) return comments;
    final records = json['records'];
    if (records is List) return records;
    final comment = json['comment'];
    if (comment is List) return comment;
    if (comment is Map) return [comment];
    return const [];
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

  @override
  Future<List<TagSuggestion>> suggestTags(
    String query, {
    int limit = 20,
  }) async {
    final cleanQuery = query
        .replaceAll(RegExp(r'^[\(\)]+|[\(\)]+$'), '')
        .trim()
        .toLowerCase();
    if (cleanQuery.isEmpty) return const [];
    try {
      final response = await _dio.get<dynamic>(
        '/tags/autocomplete.json',
        queryParameters: {
          'search[name_matches]': cleanQuery,
          'limit': limit.clamp(1, 50),
          ..._queryParameters,
        },
      );
      final items = response.data is List ? response.data as List : const [];
      return items
          .whereType<Map>()
          .map((item) {
            final json = Map<String, dynamic>.from(item);
            final name = (json['value'] ?? json['name'] ?? '').toString();
            return TagSuggestion(
              name: name,
              category: tagCategoryFromString(json['category']?.toString()),
              postCount: _int(json['post_count']),
              providerId: id,
            );
          })
          .where((tag) => tag.name.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
