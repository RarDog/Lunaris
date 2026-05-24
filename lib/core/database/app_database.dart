import 'dart:convert';

import 'package:isar/isar.dart' hide Collection;
import 'package:path_provider/path_provider.dart';

import '../../backend/models/collection.dart';
import '../../backend/models/content_provider_config.dart';
import '../../backend/models/favorite.dart';
import '../../backend/models/post.dart';
import '../../backend/models/provider_diagnostics.dart';
import '../../backend/models/provider_health.dart';
import '../../backend/models/search_history.dart';
import '../../backend/models/viewed_post.dart';

part 'app_database.g.dart';

class AppDatabase {
  AppDatabase(this.isar);

  final Isar isar;

  static Future<AppDatabase> open({String? directory}) async {
    final dir = directory ?? (await getApplicationDocumentsDirectory()).path;
    final isar = await Isar.open(
      [
        ProviderConfigEntitySchema,
        ProviderHealthEntitySchema,
        CachedPostEntitySchema,
        FavoriteEntitySchema,
        CollectionEntitySchema,
        CollectionPostEntitySchema,
        SearchHistoryEntitySchema,
        AppSettingEntitySchema,
        ViewedPostEntitySchema,
        ProviderDiagnosticsEntitySchema,
      ],
      directory: dir,
      name: 'gel_rule_app',
    );
    return AppDatabase(isar);
  }

  Future<void> close() => isar.close();
}

@collection
class ProviderConfigEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String providerId;
  late String name;
  late String baseUrl;
  late String apiType;
  late bool enabled;
  late int priority;
  late int timeoutSeconds;
  late String customHeadersJson;
  late DateTime createdAt;
  late DateTime updatedAt;

  ContentProviderConfig toModel() => ContentProviderConfig(
        id: providerId,
        name: name,
        baseUrl: baseUrl,
        apiType: apiType,
        enabled: enabled,
        priority: priority,
        timeoutSeconds: timeoutSeconds,
        customHeaders: Map<String, String>.from(
          jsonDecode(customHeadersJson) as Map,
        ),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static ProviderConfigEntity fromModel(ContentProviderConfig model) {
    return ProviderConfigEntity()
      ..providerId = model.id
      ..name = model.name
      ..baseUrl = model.baseUrl
      ..apiType = model.apiType
      ..enabled = model.enabled
      ..priority = model.priority
      ..timeoutSeconds = model.timeoutSeconds
      ..customHeadersJson = jsonEncode(model.customHeaders)
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }
}

@collection
class ProviderHealthEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String providerId;
  @enumerated
  late ProviderStatus status;
  late int pingMs;
  late DateTime lastCheckedAt;
  String? errorMessage;
  String? apiVersion;

  ProviderHealth toModel() => ProviderHealth(
        providerId: providerId,
        status: status,
        pingMs: pingMs,
        lastCheckedAt: lastCheckedAt,
        errorMessage: errorMessage,
        apiVersion: apiVersion,
      );

  static ProviderHealthEntity fromModel(ProviderHealth model) {
    return ProviderHealthEntity()
      ..providerId = model.providerId
      ..status = model.status
      ..pingMs = model.pingMs
      ..lastCheckedAt = model.lastCheckedAt
      ..errorMessage = model.errorMessage
      ..apiVersion = model.apiVersion;
  }
}

@collection
class CachedPostEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String cacheKey;
  @Index(composite: [CompositeIndex('postId')])
  late String providerId;
  late String postId;
  late String providerName;
  late String previewUrl;
  late String sampleUrl;
  late String fileUrl;
  late List<String> tags;
  late String tagGroupsJson;
  late String rating;
  late int width;
  late int height;
  String? source;
  late DateTime createdAt;
  late String fileType;
  late int score;
  late DateTime cachedAt;

  Post toModel() => Post(
        id: postId,
        providerId: providerId,
        providerName: providerName,
        previewUrl: previewUrl,
        sampleUrl: sampleUrl,
        fileUrl: fileUrl,
        tags: tags,
        tagGroups: _decodeTagGroups(tagGroupsJson),
        rating: rating,
        width: width,
        height: height,
        source: source,
        createdAt: createdAt,
        fileType: fileType,
        score: score,
      );

  static CachedPostEntity fromModel(Post model, {DateTime? cachedAt}) {
    return CachedPostEntity()
      ..cacheKey = model.cacheKey
      ..providerId = model.providerId
      ..postId = model.id
      ..providerName = model.providerName
      ..previewUrl = model.previewUrl
      ..sampleUrl = model.sampleUrl
      ..fileUrl = model.fileUrl
      ..tags = model.tags
      ..tagGroupsJson = jsonEncode(model.tagGroups)
      ..rating = model.rating
      ..width = model.width
      ..height = model.height
      ..source = model.source
      ..createdAt = model.createdAt
      ..fileType = model.fileType
      ..score = model.score
      ..cachedAt = cachedAt ?? DateTime.now();
  }

  static Map<String, List<String>> _decodeTagGroups(String value) {
    if (value.isEmpty) return const {};
    final decoded = jsonDecode(value) as Map;
    return decoded.map(
      (key, value) => MapEntry(
        key.toString(),
        List<String>.from((value as List?) ?? const []),
      ),
    );
  }
}

@collection
class FavoriteEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String favoriteKey;
  late String favoriteId;
  late String postId;
  late String providerId;
  late DateTime savedAt;

  Favorite toModel() => Favorite(
        id: favoriteId,
        postId: postId,
        providerId: providerId,
        savedAt: savedAt,
      );
}

@collection
class CollectionEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String collectionId;
  late String name;
  String? description;
  String? coverUrl;
  late DateTime createdAt;
  late DateTime updatedAt;

  Collection toModel() => Collection(
        id: collectionId,
        name: name,
        description: description,
        coverUrl: coverUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

@collection
class CollectionPostEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String linkKey;
  @Index()
  late String collectionId;
  late String postId;
  late String providerId;
  late DateTime addedAt;
}

@collection
class SearchHistoryEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String historyId;
  late String query;
  late List<String> tags;
  late DateTime searchedAt;
  late int resultCount;

  SearchHistory toModel() => SearchHistory(
        id: historyId,
        query: query,
        tags: tags,
        searchedAt: searchedAt,
        resultCount: resultCount,
      );
}

@collection
class AppSettingEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;
  late String jsonValue;
  late DateTime updatedAt;
}

@collection
class ViewedPostEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String viewedKey;
  @Index(composite: [CompositeIndex('postId')])
  late String providerId;
  late String postId;
  late DateTime viewedAt;

  ViewedPost toModel() => ViewedPost(
        viewedKey: viewedKey,
        providerId: providerId,
        postId: postId,
        viewedAt: viewedAt,
      );

  static ViewedPostEntity fromModel(ViewedPost model) {
    return ViewedPostEntity()
      ..viewedKey = model.viewedKey
      ..providerId = model.providerId
      ..postId = model.postId
      ..viewedAt = model.viewedAt;
  }
}

@collection
class ProviderDiagnosticsEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String providerId;
  late DateTime lastSearchAt;
  late int lastResultCount;
  String? lastErrorMessage;

  ProviderDiagnostics toModel() => ProviderDiagnostics(
        providerId: providerId,
        lastSearchAt: lastSearchAt,
        lastResultCount: lastResultCount,
        lastErrorMessage: lastErrorMessage,
      );

  static ProviderDiagnosticsEntity fromModel(ProviderDiagnostics model) {
    return ProviderDiagnosticsEntity()
      ..providerId = model.providerId
      ..lastSearchAt = model.lastSearchAt
      ..lastResultCount = model.lastResultCount
      ..lastErrorMessage = model.lastErrorMessage;
  }
}
