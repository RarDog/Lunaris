import '../../core/errors/app_exception.dart';
import '../mappers/gelbooru_mapper.dart';
import '../models/post.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import 'gelbooru_provider.dart';

class RealbooruProvider extends GelbooruProvider {
  RealbooruProvider({
    required super.id,
    required super.name,
    required super.baseUrl,
    required super.dioClient,
    super.queryParameters,
  });

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
      if (topPeriod == TopPeriodFilter.allTime) 'sort:score:desc',
    ];
    final response = await dio.get<dynamic>(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'post',
        'q': 'index',
        'pid': page,
        'limit': limit.clamp(1, 100),
        'tags': queryTags.join(' '),
        ...queryParameters,
      },
    );
    _throwIfSearchFailed(response.data);
    return GelbooruMapper.postsFromResponse(
      response.data,
      providerId: id,
      providerName: name,
    );
  }

  @override
  Future<Post?> getPost(String id) async {
    final response = await dio.get<dynamic>(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'post',
        'q': 'index',
        'id': id,
        ...queryParameters,
      },
    );
    _throwIfSearchFailed(response.data);
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
      final response = await dio.get<dynamic>(
        '/index.php',
        queryParameters: {
          'page': 'dapi',
          's': 'post',
          'q': 'index',
          'limit': 1,
          ...queryParameters,
        },
      );
      _throwIfSearchFailed(response.data);
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: 'realbooru-dapi',
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
        apiVersion: 'realbooru-dapi',
      );
    }
  }

  void _throwIfSearchFailed(dynamic data) {
    if (data is Map) {
      final success = data['success']?.toString().toLowerCase();
      if (success == 'false') {
        throw ProviderUnavailableException(
          (data['message'] ??
                  data['reason'] ??
                  'Realbooru search is unavailable')
              .toString(),
        );
      }
    }
    final text = data?.toString().toLowerCase() ?? '';
    if (text.contains('success="false"') || text.contains("success='false'")) {
      final message = RegExp(r'''(?:message|reason)\s*=\s*["']([^"']+)["']''')
          .firstMatch(data?.toString() ?? '');
      throw ProviderUnavailableException(
        message?.group(1) ?? 'Realbooru search is unavailable',
      );
    }
  }
}
