import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../mappers/danbooru_mapper.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class DanbooruProvider implements ContentProvider, CommentProvider {
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
        'page': page <= 0 ? 1 : page,
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
    final data = response.data;
    final items = data is List ? data : const [];
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

  List<String> _topTags(TopPeriodFilter period) {
    return switch (period) {
      TopPeriodFilter.none => const [],
      TopPeriodFilter.month || TopPeriodFilter.year => const ['order:rank'],
      TopPeriodFilter.allTime => const ['order:score'],
    };
  }
}
