import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../mappers/e621_mapper.dart';
import '../models/post.dart';
import '../models/provider_health.dart';
import '../models/tag_suggestion.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class E621Provider implements ContentProvider, TagSuggestionProvider {
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

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    final response = await _dio.get<dynamic>(
      '/posts.json',
      queryParameters: {
        'page': page <= 0 ? 1 : page,
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

  String _rating(String value) {
    return switch (value.toLowerCase()) {
      'safe' => 's',
      'questionable' => 'q',
      'explicit' => 'e',
      _ => value,
    };
  }

  List<String> _topTags(TopPeriodFilter period) {
    return switch (period) {
      TopPeriodFilter.none => const [],
      TopPeriodFilter.month => const ['order:rank'],
      TopPeriodFilter.year || TopPeriodFilter.allTime => const ['order:score'],
    };
  }

  int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
