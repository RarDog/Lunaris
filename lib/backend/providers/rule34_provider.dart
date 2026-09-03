import '../mappers/rule34_mapper.dart';
import '../models/post.dart';
import '../models/top_period_filter.dart';
import 'gelbooru_provider.dart';

class Rule34Provider extends GelbooruProvider {
  Rule34Provider({
    required super.id,
    required super.name,
    required super.baseUrl,
    required super.dioClient,
    super.queryParameters,
  });

  @override
  String postPageUrl(Post post) =>
      'https://rule34.xxx/index.php?page=post&s=view&id=${post.id}';

  @override
  Map<String, String> mediaHeaders(Post post) => const {
        'User-Agent': 'Lunaris/2.0.1 Flutter local booru browser',
        'Accept': '*/*',
        'Referer': 'https://rule34.xxx/',
      };

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    final topTags = switch (topPeriod) {
      TopPeriodFilter.none => const <String>[],
      TopPeriodFilter.month || TopPeriodFilter.year => const <String>[],
      TopPeriodFilter.allTime => const ['sort:score:desc'],
    };
    final response = await dio.get<dynamic>(
      '/index.php',
      queryParameters: {
        'page': 'dapi',
        's': 'post',
        'q': 'index',
        'json': '1',
        'pid': page,
        'limit': limit,
        'tags': [
          ...tags,
          if (rating != null) 'rating:$rating',
          ...topTags,
        ].join(' '),
        ...queryParameters,
      },
    );
    return Rule34Mapper.postsFromResponse(
      response.data,
      providerId: id,
      providerName: name,
    );
  }
}
