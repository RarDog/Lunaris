import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../models/artist_profile.dart';
import '../models/artist_work_query.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class KemonoProvider
    implements ContentProvider, ArtistProvider, CommentProvider {
  KemonoProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required DioClient dioClient,
    Map<String, String> queryParameters = const {},
  })  : _dio = dioClient.dio,
        _creatorDio = Dio(
          BaseOptions(
            baseUrl: queryParameters['creator_api_base'] ??
                'https://kemono-api.mbaharip.com',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'Lunaris/1.1 Flutter local booru browser',
            },
          ),
        );

  @override
  final String id;

  @override
  final String name;

  @override
  final String baseUrl;

  final Dio _dio;
  final Dio _creatorDio;

  bool get _isCoomer =>
      id.toLowerCase().contains('coomer') ||
      baseUrl.toLowerCase().contains('coomer');

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    return const [];
  }

  @override
  Future<Post?> getPost(String id) async => null;

  @override
  Future<ProviderHealth> checkHealth() async {
    final startedAt = DateTime.now();
    try {
      await _creatorDio.get<dynamic>(
        _creatorPath(),
        queryParameters: {'page': 1, 'itemsPerPage': 1},
      );
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: _isCoomer ? 'coomer-artists' : 'kemono-artists',
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
        apiVersion: _isCoomer ? 'coomer-artists' : 'kemono-artists',
      );
    }
  }

  @override
  Future<List<ArtistProfile>> listArtists({
    String? service,
    String? query,
    int page = 1,
    int limit = 30,
  }) async {
    final searchText = query?.trim() ?? '';
    if (searchText.isNotEmpty) {
      try {
        final response = await _creatorDio.get<dynamic>(
          '/search',
          queryParameters: {
            'q': searchText,
            'query': searchText,
            'site': _isCoomer ? 'coomer' : 'kemono',
            'page': page,
            'itemsPerPage': limit.clamp(1, 100),
          },
        );
        final artists = _artistsFromResponse(response.data)
            .where((artist) =>
                service == null || service.isEmpty || artist.service == service)
            .toList(growable: false);
        if (artists.isNotEmpty) return artists;
      } catch (_) {
        // Fall through to the indexed creator endpoints.
      }
    }
    try {
      final response = await _creatorDio.get<dynamic>(
        service == null || service.isEmpty
            ? _creatorPath()
            : '${_creatorPath()}/$service',
        queryParameters: {
          'page': page,
          'itemsPerPage': limit.clamp(1, 100),
          if (query != null && query.trim().isNotEmpty) 'keyword': query.trim(),
        },
      );
      return _artistsFromResponse(response.data);
    } catch (_) {
      return _listArtistsFromPublicApi(
        service: service,
        query: query,
        page: page,
        limit: limit,
      );
    }
  }

  @override
  Future<List<ArtistProfile>> searchArtists(
    String query, {
    String? service,
    int page = 1,
    int limit = 30,
  }) {
    return listArtists(
        service: service, query: query, page: page, limit: limit);
  }

  @override
  Future<List<Post>> getArtistPosts({
    required ArtistWorkQuery query,
    int page = 0,
    int limit = 50,
  }) async {
    Object? lastError;
    final paths = [
      '/api/v1/${query.service}/user/${query.artistId}/posts',
      '/api/v1/${query.service}/user/${query.artistId}',
    ];
    for (final apiBase in _apiBaseCandidates()) {
      for (final path in paths) {
        try {
          final response = await _getFromApiBase<dynamic>(
            apiBase,
            path,
            queryParameters: {'o': page * limit},
          );
          final posts = _postItems(response.data);
          final mapped = <Post>[];
          for (final post in posts.whereType<Map>()) {
            mapped.addAll(_postsFromArtistPost(
              Map<String, dynamic>.from(post),
              query: query,
              mediaBaseUrl: apiBase,
            ));
          }
          if (mapped.isNotEmpty || posts.isEmpty) {
            return mapped.take(limit).toList(growable: false);
          }
        } catch (error) {
          lastError = error;
        }
      }
    }
    throw StateError(
      '$name artist works are unavailable right now. Try again later. '
      '${_shortError(lastError)}',
    );
  }

  @override
  Future<List<PostComment>> getArtistPostComments(
    String service,
    String artistId,
    String postId,
  ) async {
    Object? lastError;
    final path = '/api/v1/$service/user/$artistId/post/$postId/comments';
    for (final apiBase in _apiBaseCandidates()) {
      try {
        final response = await _getFromApiBase<dynamic>(apiBase, path);
        return _commentsFromResponse(response.data, postId);
      } catch (error) {
        lastError = error;
      }
    }
    throw StateError(
      '$name comments are unavailable right now. ${_shortError(lastError)}',
    );
  }

  @override
  Future<List<PostComment>> getComments(String postId) async {
    final parts = postId.split(':');
    if (parts.length < 4) return const [];
    return getArtistPostComments(parts[0], parts[1], parts[2]);
  }

  String _creatorPath() => _isCoomer ? '/coomer' : '/kemono';

  List<ArtistProfile> _artistsFromResponse(dynamic data) {
    final items = data is Map ? data['data'] : data;
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          final service = (json['service'] ?? '').toString();
          final artistId =
              (json['id'] ?? json['creator_id'] ?? json['user_id'] ?? '')
                  .toString();
          final name = (json['name'] ??
                  json['display_name'] ??
                  json['username'] ??
                  artistId)
              .toString();
          final rawAvatar = (json['avatar'] ??
                  json['icon'] ??
                  json['image'] ??
                  json['avatar_url'] ??
                  '')
              .toString();
          return ArtistProfile(
            id: artistId,
            providerId: id,
            service: service,
            name: name,
            displayName: name,
            avatarUrl: _absoluteUrl(rawAvatar) ?? _iconUrl(service, artistId),
            updatedAt: _dateFromAny(json['updated']),
            postCount: (json['post_count'] as num?)?.toInt(),
            url: '$baseUrl/$service/user/$artistId',
          );
        })
        .where((artist) => artist.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<ArtistProfile>> _listArtistsFromPublicApi({
    String? service,
    String? query,
    required int page,
    required int limit,
  }) async {
    Object? lastError;
    dynamic data;
    for (final apiBase in _apiBaseCandidates()) {
      try {
        final response =
            await _getFromApiBase<dynamic>(apiBase, '/api/v1/creators.txt');
        data = response.data;
        break;
      } catch (error) {
        lastError = error;
      }
    }
    if (data == null) {
      throw StateError(
        '$name artist index is unavailable right now. ${_shortError(lastError)}',
      );
    }
    final queryText = (query ?? '').trim().toLowerCase();
    final offset = (page - 1).clamp(0, 999999) * limit;
    final items = _artistsFromResponse({'data': data})
        .where((artist) =>
            (service == null || service.isEmpty || artist.service == service) &&
            (queryText.isEmpty ||
                artist.displayName.toLowerCase().contains(queryText) ||
                artist.id.toLowerCase().contains(queryText)))
        .toList(growable: false);
    return items.skip(offset).take(limit).toList(growable: false);
  }

  List<dynamic> _postItems(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final results = data['results'];
      if (results is List) return results;
      final posts = data['posts'];
      if (posts is List) return posts;
      if (posts is Map) return _postItems(posts);
      final dataItems = data['data'];
      if (dataItems is List) return dataItems;
    }
    return const [];
  }

  List<Post> _postsFromArtistPost(
    Map<String, dynamic> json, {
    required ArtistWorkQuery query,
    required String mediaBaseUrl,
  }) {
    final postId = (json['id'] ?? json['post_id'] ?? '').toString();
    final title = (json['title'] ?? '').toString();
    final published = _dateFromAny(json['published']) ??
        _dateFromAny(json['added']) ??
        _dateFromAny(json['edited']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final files = <Map<String, dynamic>>[];
    final file = json['file'];
    if (file is Map && file.isNotEmpty) {
      files.add(Map<String, dynamic>.from(file));
    }
    final attachments = json['attachments'];
    if (attachments is List) {
      files.addAll(attachments.whereType<Map>().map(Map<String, dynamic>.from));
    }
    var index = 0;
    return files
        .map((file) {
          final url = _mediaUrl(file, mediaBaseUrl: mediaBaseUrl);
          final fileName =
              (file['name'] ?? Uri.tryParse(url)?.pathSegments.last ?? '')
                  .toString();
          final type = _fileType('$fileName $url');
          final stableId =
              '${query.service}:${query.artistId}:$postId:${index++}';
          final tags = [
            query.service,
            query.artistName,
            if (title.trim().isNotEmpty) title.trim(),
          ];
          return Post(
            id: stableId,
            providerId: id,
            providerName: name,
            previewUrl: url,
            sampleUrl: url,
            fileUrl: url,
            tags: tags,
            rating: 'unknown',
            width: 0,
            height: 0,
            source:
                '$baseUrl/${query.service}/user/${query.artistId}/post/$postId',
            createdAt: published,
            fileType: type,
            score: 0,
            tagGroups: {
              'artist': [query.artistName],
              'meta': [query.service],
              if (title.trim().isNotEmpty) 'copyright': [title.trim()],
            },
          );
        })
        .where((post) => post.fileUrl.isNotEmpty)
        .toList(growable: false);
  }

  List<PostComment> _commentsFromResponse(dynamic data, String postId) {
    final items = data is Map ? (data['comments'] ?? data['data']) : data;
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          return PostComment(
            id: (json['id'] ?? json['comment_id'] ?? '').toString(),
            postId: postId,
            providerId: id,
            authorName: (json['author'] ??
                    json['username'] ??
                    json['user'] ??
                    json['creator_name'] ??
                    'user')
                .toString(),
            body: (json['content'] ?? json['body'] ?? json['comment'] ?? '')
                .toString(),
            createdAt: _dateFromAny(json['added']) ??
                _dateFromAny(json['created_at']) ??
                DateTime.fromMillisecondsSinceEpoch(0),
          );
        })
        .where((comment) => comment.body.trim().isNotEmpty)
        .toList(growable: false);
  }

  String _mediaUrl(
    Map<String, dynamic> file, {
    required String mediaBaseUrl,
  }) {
    final path = (file['path'] ?? file['url'] ?? '').toString();
    if (path.isEmpty) return '';
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    if (path.startsWith('/data/')) {
      return '$mediaBaseUrl$path';
    }
    if (path.startsWith('/')) {
      return '$mediaBaseUrl/data$path';
    }
    return '$mediaBaseUrl/data/$path';
  }

  String? _iconUrl(String service, String artistId) {
    if (service.isEmpty || artistId.isEmpty) return null;
    final host = _isCoomer ? 'https://img.coomer.su' : 'https://img.kemono.su';
    return '$host/icons/$service/$artistId';
  }

  String? _absoluteUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) return trimmed;
    if (trimmed.startsWith('/')) return '$baseUrl$trimmed';
    return '$baseUrl/$trimmed';
  }

  List<String> _apiBaseCandidates() {
    final candidates = <String>[
      baseUrl,
      if (_isCoomer) ...[
        'https://coomer.st',
        'https://coomer.su',
      ] else ...[
        'https://kemono.cr',
        'https://kemono.su',
      ],
    ];
    return candidates.map(_trimTrailingSlash).toSet().toList(growable: false);
  }

  Future<Response<T>> _getFromApiBase<T>(
    String apiBase,
    String path, {
    Map<String, Object?> queryParameters = const {},
  }) {
    if (_trimTrailingSlash(apiBase) == _trimTrailingSlash(baseUrl)) {
      return _dio.get<T>(path, queryParameters: queryParameters);
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: apiBase,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 25),
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'Lunaris/1.1 Flutter local booru browser',
        },
      ),
    );
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  String _trimTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;

  String _shortError(Object? error) {
    if (error == null) return '';
    final message = error.toString();
    if (message.length <= 160) return message;
    return '${message.substring(0, 160)}...';
  }

  String _fileType(String value) {
    final lower = value.toLowerCase().split('?').first;
    if (lower.endsWith('.webm') || lower.endsWith('.mp4')) return 'video';
    if (lower.endsWith('.gif')) return 'gif';
    if (lower.endsWith('.swf')) return 'swf';
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return 'photo';
    }
    return 'unknown';
  }

  DateTime? _dateFromAny(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      final raw = value.toInt();
      if (raw > 9999999999) return DateTime.fromMillisecondsSinceEpoch(raw);
      return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    }
    return DateTime.tryParse(value.toString());
  }
}
