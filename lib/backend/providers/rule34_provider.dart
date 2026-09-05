import 'package:dio/dio.dart';

import '../mappers/rule34_mapper.dart';
import '../models/post.dart';
import '../models/tag_suggestion.dart';
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
        'User-Agent': 'Prisma/2.0.1 Flutter local booru browser',
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
    try {
      final response = await dio.get<dynamic>(
        '/index.php',
        queryParameters: {
          'page': 'dapi',
          's': 'post',
          'q': 'index',
          'json': '1',
          'pid': page,
          'limit': limit,
          'fields': 'tag_info',
          'tags': [
            ...tags,
            if (rating != null) 'rating:$rating',
            ...topTags,
          ].join(' '),
          ...queryParameters,
        },
      );
      _checkRule34Response(response);
      return Rule34Mapper.postsFromResponse(
        response.data,
        providerId: id,
        providerName: name,
      );
    } on DioException catch (e) {
      _handleRule34DioError(e);
    }
  }

  @override
  Future<Post?> getPost(String id) async {
    try {
      final response = await dio.get<dynamic>(
        '/index.php',
        queryParameters: {
          'page': 'dapi',
          's': 'post',
          'q': 'index',
          'json': '1',
          'id': id,
          'fields': 'tag_info',
          ...queryParameters,
        },
      );
      _checkRule34Response(response);
      final posts = Rule34Mapper.postsFromResponse(
        response.data,
        providerId: this.id,
        providerName: name,
      );
      return posts.isEmpty ? null : posts.first;
    } on DioException catch (e) {
      _handleRule34DioError(e);
    }
  }

  @override
  Future<List<TagSuggestion>> suggestTags(String query,
      {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    try {
      // Official Rule34 autocomplete endpoint (fast, public, with exact post count)
      final response = await dio.get<dynamic>(
        '/autocomplete.php',
        queryParameters: {
          'q': trimmed,
        },
      );
      if (response.data is List) {
        final list = response.data as List;
        final suggestions = list
            .whereType<Map>()
            .map((item) {
              final json = Map<String, dynamic>.from(item);
              final rawLabel = (json['label'] ?? '').toString();
              final rawValue = (json['value'] ?? '').toString();
              // Parse label "braid (216984)" -> name: "braid", postCount: 216984
              final match =
                  RegExp(r'^(.*?)\s*\((\d+)\)$').firstMatch(rawLabel);
              final name = (match?.group(1) ?? rawValue).trim();
              final postCount = int.tryParse(match?.group(2) ?? '') ?? 0;
              return TagSuggestion(
                name: name.isNotEmpty ? name : rawValue,
                category: TagCategory.general,
                postCount: postCount,
                providerId: id,
              );
            })
            .where((tag) => tag.name.isNotEmpty)
            .take(limit)
            .toList(growable: false);
        if (suggestions.isNotEmpty) return suggestions;
      }
    } catch (_) {
      // Gracefully fall back to standard DAPI tag search
    }
    return super.suggestTags(query, limit: limit);
  }

  void _checkRule34Response(Response<dynamic> response) {
    if (response.data is String) {
      final text = (response.data as String).toLowerCase();
      if (text.contains('missing authentication') ||
          text.contains('throttled') ||
          text.contains('authentication required')) {
        unavailable(
          '$name requires authentication. '
          'Please configure your API Key and User ID in Settings -> Providers '
          '(obtain from https://rule34.xxx/index.php?page=account&s=options).',
        );
      }
      if (text.contains('search down') ||
          text.contains('server is overloaded')) {
        unavailable(
          '$name searcher is temporarily down or overloaded. Please try again in a few minutes.',
        );
      }
    } else if (response.data is Map) {
      final map = response.data as Map;
      if (map['success'] == false || map['success'] == 'false') {
        final msg = map['message'] ?? 'search down';
        unavailable('$name error: $msg');
      }
    }
  }

  Never _handleRule34DioError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403 || status == 429) {
      unavailable(
        '$name requires authentication or rate limit reached ($status). '
        'Please enter your API Key and User ID in Settings -> Providers.',
      );
    }
    throw error;
  }
}
