import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../models/artist_profile.dart';
import '../models/artist_work_query.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class PawchiveProvider
    implements ContentProvider, ArtistProvider, CommentProvider {
  PawchiveProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required DioClient dioClient,
    Map<String, String> queryParameters = const {},
  }) : _dio = dioClient.dio;

  @override
  final String id;

  @override
  final String name;

  @override
  final String baseUrl;

  final Dio _dio;
  List<ArtistProfile>? _cachedArtists;
  DateTime? _lastCreatorsFetchAt;

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
  Future<Post?> getPost(String id) async {
    final parts = id.split(':');
    if (parts.length < 3) return null;
    final service = parts[0];
    final artistId = parts[1];
    final postId = parts[2];
    final targetIndex = parts.length > 3 ? int.tryParse(parts[3]) ?? 0 : 0;

    final query = ArtistWorkQuery(
      providerId: this.id,
      service: service,
      artistId: artistId,
      artistName: artistId,
    );

    try {
      final response = await _dio.get<dynamic>(
        '/api/v1/$service/user/$artistId/post/$postId',
      );
      final data = response.data;
      if (data is Map) {
        final posts = _postsFromArtistPost(
          Map<String, dynamic>.from(data),
          query: query,
        );
        if (targetIndex >= 0 && targetIndex < posts.length) {
          return posts[targetIndex];
        }
        if (posts.isNotEmpty) return posts.first;
      }
    } catch (_) {
      // Fallback: search within artist posts
      try {
        final posts = await getArtistPosts(query: query, page: 0, limit: 50);
        for (final post in posts) {
          if (post.id == id) return post;
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<ProviderHealth> checkHealth() async {
    final startedAt = DateTime.now();
    try {
      final response = await _dio.get<dynamic>(
        '/api/v1/app_version',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final version = response.data?.toString().trim() ?? 'ok';
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.online,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        apiVersion: 'pawchive-$version',
      );
    } catch (error) {
      return ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: DateTime.now().difference(startedAt).inMilliseconds,
        lastCheckedAt: DateTime.now(),
        errorMessage: error.toString(),
        apiVersion: 'pawchive',
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
    final allArtists = await _ensureArtistsLoaded();
    final queryText = (query ?? '').trim().toLowerCase();
    final filtered = allArtists.where((artist) {
      final matchService = service == null ||
          service.isEmpty ||
          artist.service.toLowerCase() == service.toLowerCase();
      if (!matchService) return false;
      if (queryText.isEmpty) return true;
      return artist.displayName.toLowerCase().contains(queryText) ||
          artist.id.toLowerCase().contains(queryText);
    }).toList(growable: false);

    final ranked = _rankArtists(filtered, queryText);
    final offset = (page - 1).clamp(0, 999999) * limit;
    return ranked.skip(offset).take(limit).toList(growable: false);
  }

  @override
  Future<List<ArtistProfile>> searchArtists(
    String query, {
    String? service,
    int page = 1,
    int limit = 30,
  }) {
    return listArtists(
      service: service,
      query: query,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<Post>> getArtistPosts({
    required ArtistWorkQuery query,
    int page = 0,
    int limit = 50,
  }) async {
    final path = '/api/v1/${query.service}/user/${query.artistId}/posts';
    final offset = page * limit;
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: {'o': offset},
      );
      final posts = _postItems(response.data);
      final mapped = <Post>[];
      for (final post in posts.whereType<Map>()) {
        mapped.addAll(_postsFromArtistPost(
          Map<String, dynamic>.from(post),
          query: query,
        ));
      }
      mapped.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return mapped.toList(growable: false);
    } catch (error) {
      throw StateError(
        '$name artist posts are unavailable right now. ${_shortError(error)}',
      );
    }
  }

  @override
  Future<List<PostComment>> getArtistPostComments(
    String service,
    String artistId,
    String postId,
  ) async {
    final path = '/api/v1/$service/user/$artistId/post/$postId/comments';
    try {
      final response = await _dio.get<dynamic>(path);
      return _commentsFromResponse(response.data, postId);
    } catch (error) {
      // 404 means no comments found, return empty list
      if (error is DioException && error.response?.statusCode == 404) {
        return const [];
      }
      return const [];
    }
  }

  @override
  Future<List<PostComment>> getComments(String postId) async {
    final parts = postId.split(':');
    if (parts.length < 3) return const [];
    return getArtistPostComments(parts[0], parts[1], parts[2]);
  }

  Future<List<ArtistProfile>> _ensureArtistsLoaded() async {
    final cached = _cachedArtists;
    final lastFetch = _lastCreatorsFetchAt;
    if (cached != null &&
        lastFetch != null &&
        DateTime.now().difference(lastFetch) < const Duration(minutes: 30)) {
      return cached;
    }
    try {
      final response = await _dio.get<dynamic>(
        '/api/v1/creators',
        options: Options(
          receiveTimeout: const Duration(seconds: 25),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      final artists = _artistsFromResponse(response.data);
      _cachedArtists = artists;
      _lastCreatorsFetchAt = DateTime.now();
      return artists;
    } catch (error) {
      if (cached != null) return cached;
      throw StateError('Failed to load $name creators: ${_shortError(error)}');
    }
  }

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
          final iconUrl = '$baseUrl/icons/$service/$artistId';
          return ArtistProfile(
            id: artistId,
            providerId: id,
            service: service,
            name: name,
            displayName: name,
            avatarUrl: iconUrl,
            updatedAt: _dateFromAny(json['updated']),
            postCount: (json['favorited'] as num?)?.toInt(),
            url: '$baseUrl/$service/user/$artistId',
          );
        })
        .where((artist) => artist.id.isNotEmpty)
        .toList(growable: false);
  }

  List<Post> _postsFromArtistPost(
    Map<String, dynamic> json, {
    required ArtistWorkQuery query,
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
        .map((fileMap) {
          final rawPath = (fileMap['path'] ?? '').toString();
          final fileName = (fileMap['name'] ?? '').toString();
          final previewOnly = fileMap['preview_only'] == true;

          final previewUrl = _thumbnailUrl(rawPath);
          final fileUrl = previewOnly
              ? previewUrl
              : _fileDownloadUrl(rawPath, fileName);

          final type = _fileType('$fileName $rawPath');
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
            previewUrl: previewUrl,
            sampleUrl: previewUrl,
            fileUrl: fileUrl,
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

  String _thumbnailUrl(String path) {
    if (path.isEmpty) return '';
    final trimmed = path.startsWith('/') ? path : '/$path';
    return 'https://img.pawchive.pw/thumbnail/data$trimmed';
  }

  String _fileDownloadUrl(String path, String fileName) {
    if (path.isEmpty) return '';
    final trimmed = path.startsWith('/') ? path : '/$path';
    final base = 'https://file.pawchive.pw/data$trimmed';
    if (fileName.isEmpty) return base;
    return '$base?f=${Uri.encodeComponent(fileName)}';
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
            authorName: (json['commenter'] ??
                    json['author'] ??
                    json['username'] ??
                    'user')
                .toString(),
            body: (json['content'] ?? json['body'] ?? json['comment'] ?? '')
                .toString(),
            createdAt: _dateFromAny(json['published']) ??
                _dateFromAny(json['added']) ??
                DateTime.fromMillisecondsSinceEpoch(0),
          );
        })
        .where((comment) => comment.id.isNotEmpty && comment.body.isNotEmpty)
        .toList(growable: false);
  }

  List<dynamic> _postItems(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final posts = data['posts'] ?? data['data'] ?? data['results'];
      if (posts is List) return posts;
    }
    return const [];
  }

  List<ArtistProfile> _rankArtists(List<ArtistProfile> artists, String query) {
    final queryText = query.trim().toLowerCase();
    final ranked = [...artists];
    ranked.sort((a, b) {
      if (queryText.isNotEmpty) {
        final aExact = a.displayName.toLowerCase() == queryText;
        final bExact = b.displayName.toLowerCase() == queryText;
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;

        final aStarts = a.displayName.toLowerCase().startsWith(queryText);
        final bStarts = b.displayName.toLowerCase().startsWith(queryText);
        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
      }
      final favA = a.postCount ?? 0;
      final favB = b.postCount ?? 0;
      if (favA != favB) return favB.compareTo(favA);
      final updatedA = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final updatedB = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return updatedB.compareTo(updatedA);
    });
    return ranked;
  }

  String _shortError(Object? error) {
    if (error == null) return '';
    final message = error.toString();
    if (message.length <= 160) return message;
    return '${message.substring(0, 160)}...';
  }

  String _fileType(String value) {
    final lower = value.toLowerCase().split('?').first;
    if (lower.endsWith('.webm') || lower.endsWith('.mp4') || lower.endsWith('.mov')) {
      return 'video';
    }
    if (lower.endsWith('.gif')) return 'gif';
    if (lower.endsWith('.swf')) return 'swf';
    if (lower.endsWith('.zip') || lower.endsWith('.rar') || lower.endsWith('.7z')) {
      return 'archive';
    }
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
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
