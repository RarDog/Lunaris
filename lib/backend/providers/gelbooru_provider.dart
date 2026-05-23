import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/http/dio_client.dart';
import '../mappers/gelbooru_mapper.dart';
import '../models/post.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class GelbooruProvider implements ContentProvider {
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
}
