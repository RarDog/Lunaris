import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/http/dio_client.dart';
import '../models/artist_announcement.dart';
import '../models/artist_link.dart';
import '../models/artist_profile.dart';
import '../models/artist_tag.dart';
import '../models/artist_work_query.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import '../services/cloud_link_extractor.dart';
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
    final offset = (page - 1).clamp(0, 999999) * 50;
    final queryText = tags.join(' ').trim();
    try {
      final response = await _dio.get<dynamic>(
        '/api/v1/posts',
        queryParameters: {
          if (queryText.isNotEmpty) 'q': queryText,
          'o': offset,
        },
      );
      final posts = _postItems(response.data);
      final mapped = <Post>[];
      for (final post in posts.whereType<Map>()) {
        final json = Map<String, dynamic>.from(post);
        final service = (json['service'] ?? 'fanbox').toString();
        final userId = (json['user'] ?? '').toString();
        final dummyQuery = ArtistWorkQuery(
          providerId: id,
          service: service,
          artistId: userId,
          artistName: userId,
        );
        mapped.addAll(_postsFromArtistPost(json, query: dummyQuery));
      }
      return mapped;
    } catch (_) {
      return const [];
    }
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
    List<String>? services,
    String? query,
    int page = 1,
    int limit = 30,
  }) async {
    final allArtists = await _ensureArtistsLoaded();
    final queryText = (query ?? '').trim().toLowerCase();
    final activeServices = services != null && services.isNotEmpty
        ? services.map((s) => s.trim().toLowerCase()).toSet()
        : null;
    final filtered = allArtists.where((artist) {
      final artistService = artist.service.toLowerCase();
      final matchService = activeServices != null
          ? activeServices.contains(artistService)
          : service == null ||
              service.isEmpty ||
              artistService == service.toLowerCase();
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
    List<String>? services,
    int page = 1,
    int limit = 30,
  }) {
    return listArtists(
      service: service,
      services: services,
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
        queryParameters: {
          'o': offset,
          if (query.tagFilter != null && query.tagFilter!.isNotEmpty)
            'tag': query.tagFilter,
          if (query.queryText != null && query.queryText!.isNotEmpty)
            'q': query.queryText,
        },
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
  Future<List<ArtistTag>> getArtistTags(String service, String artistId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/v1/$service/user/$artistId/tags',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final items = response.data;
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => ArtistTag.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  @override
  Future<List<ArtistLink>> getArtistLinks(
      String service, String artistId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/v1/$service/user/$artistId/links',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final items = response.data;
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => ArtistLink.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  @override
  Future<List<ArtistAnnouncement>> getArtistAnnouncements(
      String service, String artistId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/v1/$service/user/$artistId/announcements',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final items = response.data;
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) =>
                ArtistAnnouncement.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false);
      }
    } catch (_) {}
    return const [];
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
    final postSource =
        '$baseUrl/${query.service}/user/${query.artistId}/post/$postId';
    final rawContent = (json['content'] ?? '').toString();
    final embed = json['embed'] is Map ? Map<String, dynamic>.from(json['embed']) : null;
    final cloudLinks = CloudLinkExtractor.extractLinks(
      content: rawContent,
      source: postSource,
      embed: embed,
    );
    final cloudLinksJson = cloudLinks.map((e) => e.encode()).toList(growable: false);
    final cleanDesc = CloudLinkExtractor.cleanCommentary(rawContent);

    final files = <Map<String, dynamic>>[];
    final file = json['file'];
    if (file is Map && file.isNotEmpty) {
      files.add(Map<String, dynamic>.from(file));
    }
    final attachments = json['attachments'];
    if (attachments is List) {
      for (final att in attachments.whereType<Map>()) {
        final m = Map<String, dynamic>.from(att);
        final path = (m['path'] ?? '').toString();
        if (path.isNotEmpty &&
            files.any((existing) => (existing['path'] ?? '').toString() == path)) {
          continue;
        }
        files.add(m);
      }
    }

    // Support link-only posts where author uploaded files to cloud drives (MEGA, GDrive, etc.)
    // or text-only posts where author wrote an announcement, status or note
    if (files.isEmpty &&
        (cloudLinks.isNotEmpty ||
            cleanDesc.isNotEmpty ||
            rawContent.trim().isNotEmpty ||
            title.trim().isNotEmpty)) {
      final stableId = '${query.service}:${query.artistId}:$postId:0';
      final firstStreamable =
          cloudLinks.where((l) => l.isStreamable).firstOrNull;
      final firstLink = cloudLinks.isNotEmpty ? cloudLinks.first : null;
      final fileUrl = firstStreamable?.directStreamUrl ?? firstLink?.url ?? '';
      final isTextOnly = cloudLinks.isEmpty;
      final tags = [
        query.service,
        query.artistName,
        if (title.trim().isNotEmpty) title.trim(),
        if (!isTextOnly) 'cloud_mirror' else 'text_post',
      ];
      return [
        Post(
          id: stableId,
          providerId: id,
          providerName: name,
          previewUrl: '',
          sampleUrl: '',
          fileUrl: fileUrl,
          tags: tags,
          rating: 'unknown',
          width: 0,
          height: 0,
          source: postSource,
          createdAt: published,
          fileType: firstStreamable != null
              ? 'video'
              : (isTextOnly ? 'text' : 'link'),
          score: 0,
          tagGroups: {
            'artist': [query.artistName],
            'meta': [query.service],
            if (title.trim().isNotEmpty) 'copyright': [title.trim()],
            if (cloudLinksJson.isNotEmpty) 'cloud_links': cloudLinksJson,
            if (cleanDesc.isNotEmpty)
              'description': [cleanDesc]
            else if (rawContent.trim().isNotEmpty)
              'description': [rawContent.trim()],
          },
        ),
      ];
    }

    // Determine if there is a cover illustration for the post
    String? postCoverUrl;
    for (final f in files) {
      final p = (f['path'] ?? '').toString();
      final n = (f['name'] ?? '').toString();
      if (_isPhotoType(p, n) && p.isNotEmpty) {
        postCoverUrl = _thumbnailUrl(p);
        break;
      }
    }

    var index = 0;
    return files
        .map((fileMap) {
          final rawPath = (fileMap['path'] ?? '').toString();
          final fileName = (fileMap['name'] ?? '').toString();
          final previewOnly = fileMap['preview_only'] == true;

          final type = _fileTypeFor(rawPath, fileName);
          final isPhoto = type == 'photo' || type == 'gif';

          // img.pawchive.pw/thumbnail only generates thumbnails for images/gifs.
          // Non-image files (audio, video, archive) return 404 from thumbnail server.
          final previewUrl = isPhoto
              ? _thumbnailUrl(rawPath)
              : (postCoverUrl ?? '');

          final fileUrl = previewOnly
              ? (isPhoto ? previewUrl : _fileDownloadUrl(rawPath, fileName))
              : _fileDownloadUrl(rawPath, fileName);

          final stableId =
              '${query.service}:${query.artistId}:$postId:${index++}';
          final tags = [
            query.service,
            query.artistName,
            if (title.trim().isNotEmpty) title.trim(),
            if (type == 'audio') 'audio',
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
            source: postSource,
            createdAt: published,
            fileType: type,
            score: 0,
            tagGroups: {
              'artist': [query.artistName],
              'meta': [query.service],
              if (title.trim().isNotEmpty) 'copyright': [title.trim()],
              if (cloudLinksJson.isNotEmpty) 'cloud_links': cloudLinksJson,
              if (cleanDesc.isNotEmpty) 'description': [cleanDesc],
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

  String _extractExtension(String value) {
    if (value.isEmpty) return '';
    final clean = value.split('?').first.split('#').first.trim();
    final dot = clean.lastIndexOf('.');
    if (dot != -1 && dot < clean.length - 1) {
      final ext = clean.substring(dot).toLowerCase();
      if (ext.length <= 6) return ext;
    }
    return '';
  }

  String _fileType(String value) {
    final ext = _extractExtension(value);
    if (const {
      '.webm',
      '.mp4',
      '.mov',
      '.mkv',
      '.avi',
      '.flv',
      '.wmv',
      '.m4v',
      '.ts',
    }.contains(ext)) {
      return 'video';
    }
    if (const {
      '.mp3',
      '.m4a',
      '.wav',
      '.ogg',
      '.flac',
      '.aac',
      '.opus',
      '.wma',
    }.contains(ext)) {
      return 'audio';
    }
    if (ext == '.gif') return 'gif';
    if (ext == '.swf') return 'swf';
    if (const {
      '.zip',
      '.rar',
      '.7z',
      '.tar',
      '.gz',
      '.pdf',
      '.txt',
    }.contains(ext)) {
      return 'archive';
    }
    if (const {
      '.png',
      '.jpg',
      '.jpeg',
      '.webp',
      '.avif',
      '.bmp',
      '.heic',
      '.tiff',
    }.contains(ext)) {
      return 'photo';
    }
    return 'unknown';
  }

  String _fileTypeFor(String path, String fileName) {
    final extName = _extractExtension(fileName);
    final extPath = _extractExtension(path);
    final ext = extName.isNotEmpty ? extName : extPath;
    return _fileType(ext);
  }

  bool _isPhotoType(String path, [String fileName = '']) {
    final type = _fileTypeFor(path, fileName);
    return type == 'photo' || type == 'gif';
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
