import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../mappers/moebooru_mapper.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/tag_suggestion.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class MoebooruProvider
    implements
        ContentProvider,
        TagSuggestionProvider,
        CommentProvider,
        PostPageProvider {
  MoebooruProvider({
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

  @override
  String postPageUrl(Post post) => '$baseUrl/post/show/${post.id}';

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    final response = await _dio.get<dynamic>(
      '/post.json',
      queryParameters: {
        'page': page + 1,
        'limit': limit.clamp(1, 100),
        'tags': [
          ...tags,
          if (rating != null && rating.isNotEmpty) 'rating:$rating',
          ..._topTags(topPeriod),
        ].join(' '),
        ..._queryParameters,
      },
    );
    return MoebooruMapper.postsFromResponse(
      response.data,
      providerId: id,
      providerName: name,
    );
  }

  @override
  Future<Post?> getPost(String id) async {
    final response = await _dio.get<dynamic>(
      '/post.json',
      queryParameters: {'id': id, 'limit': 1, ..._queryParameters},
    );
    final posts = MoebooruMapper.postsFromResponse(
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
        '/post.json',
        queryParameters: {'limit': 1, ..._queryParameters},
      );
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: 'moebooru',
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
        apiVersion: 'moebooru',
      );
    }
  }

  @override
  Future<List<TagSuggestion>> suggestTags(String query,
      {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];
    final response = await _dio.get<dynamic>(
      '/tag.json',
      queryParameters: {
        'name_pattern': '${query.trim()}*',
        'limit': limit.clamp(1, 50),
        'order': 'count',
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
            category: tagCategoryFromString(
              (json['type'] ?? json['tag_type']).toString(),
            ),
            postCount: _int(json['count'] ?? json['post_count']),
            providerId: id,
          );
        })
        .where((tag) => tag.name.isNotEmpty)
        .toList();
  }

  @override
  Future<List<PostComment>> getComments(String postId) async {
    final response = await _dio.get<dynamic>(
      '/comment.json',
      queryParameters: {
        'post_id': postId,
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
            authorName:
                (json['creator'] ?? json['author'] ?? json['user'] ?? 'user')
                    .toString(),
            body: (json['body'] ?? json['comment'] ?? json['text'] ?? '')
                .toString(),
            createdAt: DateTime.tryParse(
                  (json['created_at'] ?? json['created_on'] ?? '').toString(),
                ) ??
                DateTime.fromMillisecondsSinceEpoch(0),
          );
        })
        .where((comment) => comment.body.trim().isNotEmpty)
        .toList();
  }

  List<String> _topTags(TopPeriodFilter period) {
    return switch (period) {
      TopPeriodFilter.none => const [],
      TopPeriodFilter.month || TopPeriodFilter.year => const [],
      TopPeriodFilter.allTime => const ['order:score'],
    };
  }

  int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
