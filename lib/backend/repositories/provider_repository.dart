import 'package:isar/isar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/result.dart';
import '../models/content_provider_config.dart';
import '../models/provider_diagnostics.dart';
import '../models/provider_health.dart';

class ProviderRepository {
  ProviderRepository(this._databaseService);

  final DatabaseService _databaseService;

  static List<ContentProviderConfig> seedProviders() {
    final now = DateTime.now();
    return [
      ContentProviderConfig(
        id: 'gelbooru',
        name: 'Gelbooru',
        baseUrl: 'https://gelbooru.com',
        apiType: 'gelbooru',
        enabled: true,
        priority: 0,
        timeoutSeconds: 20,
        customHeaders: const {},
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'rule34',
        name: 'Rule34',
        baseUrl: 'https://api.rule34.xxx',
        apiType: 'rule34',
        enabled: true,
        priority: 1,
        timeoutSeconds: 20,
        customHeaders: const {},
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'safebooru',
        name: 'Safebooru',
        baseUrl: 'https://safebooru.org',
        apiType: 'gelbooru',
        enabled: true,
        priority: 2,
        timeoutSeconds: 20,
        customHeaders: const {},
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'konachan',
        name: 'Konachan',
        baseUrl: 'https://konachan.com',
        apiType: 'moebooru',
        enabled: true,
        priority: 3,
        timeoutSeconds: 20,
        customHeaders: const {},
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'yandere',
        name: 'Yande.re',
        baseUrl: 'https://yande.re',
        apiType: 'moebooru',
        enabled: true,
        priority: 4,
        timeoutSeconds: 20,
        customHeaders: const {
          'query.api_version': '2',
          'query.include_tags': '1',
          'query.filter': '1',
        },
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'e621',
        name: 'e621',
        baseUrl: 'https://e621.net',
        apiType: 'e621',
        enabled: true,
        priority: 5,
        timeoutSeconds: 20,
        customHeaders: const {
          'User-Agent': 'Lunaris/1.1 Flutter local booru browser',
        },
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'e926',
        name: 'e926',
        baseUrl: 'https://e926.net',
        apiType: 'e621',
        enabled: true,
        priority: 6,
        timeoutSeconds: 20,
        customHeaders: const {
          'User-Agent': 'Lunaris/1.1 Flutter local booru browser',
        },
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'realbooru',
        name: 'Realbooru',
        baseUrl: 'https://realbooru.com',
        apiType: 'realbooru',
        enabled: false,
        priority: 7,
        timeoutSeconds: 20,
        customHeaders: const {},
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'xbooru',
        name: 'Xbooru',
        baseUrl: 'https://xbooru.com',
        apiType: 'gelbooru',
        enabled: true,
        priority: 8,
        timeoutSeconds: 20,
        customHeaders: const {},
        createdAt: now,
        updatedAt: now,
      ),
      ContentProviderConfig(
        id: 'cosbooru',
        name: 'CosBooru',
        baseUrl: 'https://cos.lycore.co',
        apiType: 'danbooru',
        enabled: true,
        priority: 9,
        timeoutSeconds: 20,
        customHeaders: const {},
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<Result<void>> ensureSeedProviders() {
    return _databaseService.safeWrite((isar) async {
      final existingProviders =
          await isar.providerConfigEntitys.where().findAll();
      for (final provider in existingProviders) {
        if (provider.providerId == 'kemono' ||
            provider.providerId == 'coomer' ||
            provider.providerId == 'paheal') {
          await isar.providerConfigEntitys.delete(provider.isarId);
        }
      }
      await isar.providerHealthEntitys
          .filter()
          .providerIdEqualTo('paheal')
          .deleteAll();
      await isar.providerDiagnosticsEntitys
          .filter()
          .providerIdEqualTo('paheal')
          .deleteAll();
      await isar.cachedPostEntitys
          .filter()
          .providerIdEqualTo('paheal')
          .deleteAll();
      await isar.favoriteEntitys
          .filter()
          .providerIdEqualTo('paheal')
          .deleteAll();
      await isar.collectionPostEntitys
          .filter()
          .providerIdEqualTo('paheal')
          .deleteAll();
      await isar.viewedPostEntitys
          .filter()
          .providerIdEqualTo('paheal')
          .deleteAll();
      final seeds = seedProviders();
      for (final seed in seeds) {
        final exists = await isar.providerConfigEntitys
            .filter()
            .providerIdEqualTo(seed.id)
            .findFirst();
        if (exists == null) {
          await isar.providerConfigEntitys
              .put(ProviderConfigEntity.fromModel(seed));
        } else if (seed.id == 'realbooru' && exists.enabled) {
          exists.enabled = false;
          exists.updatedAt = DateTime.now();
          await isar.providerConfigEntitys.put(exists);
        } else if (seed.id == 'cosbooru' &&
            (exists.baseUrl != seed.baseUrl ||
                exists.apiType != seed.apiType)) {
          exists.name = seed.name;
          exists.baseUrl = seed.baseUrl;
          exists.apiType = seed.apiType;
          exists.enabled = seed.enabled;
          exists.priority = seed.priority;
          exists.timeoutSeconds = seed.timeoutSeconds;
          exists.updatedAt = DateTime.now();
          await isar.providerConfigEntitys.put(exists);
        }
      }
    });
  }

  Future<Result<List<ContentProviderConfig>>> getProviders({
    bool enabledOnly = false,
  }) {
    return _databaseService.safeRead((isar) async {
      final providers = enabledOnly
          ? await isar.providerConfigEntitys
              .filter()
              .enabledEqualTo(true)
              .findAll()
          : await isar.providerConfigEntitys.where().findAll();
      providers.sort((a, b) => a.priority.compareTo(b.priority));
      return providers.map((entity) => entity.toModel()).toList();
    });
  }

  Future<Result<ContentProviderConfig?>> getProvider(String id) {
    return _databaseService.safeRead((isar) async {
      final entity = await isar.providerConfigEntitys
          .filter()
          .providerIdEqualTo(id)
          .findFirst();
      return entity?.toModel();
    });
  }

  Future<Result<void>> saveProvider(ContentProviderConfig config) {
    return _databaseService.safeWrite((isar) async {
      await isar.providerConfigEntitys
          .put(ProviderConfigEntity.fromModel(config));
    });
  }

  Future<Result<void>> deleteProvider(String id) {
    return _databaseService.safeWrite((isar) async {
      await isar.providerConfigEntitys
          .filter()
          .providerIdEqualTo(id)
          .deleteAll();
      await isar.providerHealthEntitys
          .filter()
          .providerIdEqualTo(id)
          .deleteAll();
    });
  }

  Future<Result<void>> saveHealth(ProviderHealth health) {
    return _databaseService.safeWrite((isar) async {
      await isar.providerHealthEntitys
          .put(ProviderHealthEntity.fromModel(health));
    });
  }

  Future<Result<ProviderHealth?>> getHealth(String providerId) {
    return _databaseService.safeRead((isar) async {
      final entity = await isar.providerHealthEntitys
          .filter()
          .providerIdEqualTo(providerId)
          .findFirst();
      return entity?.toModel();
    });
  }

  Future<Result<void>> saveDiagnostics(ProviderDiagnostics diagnostics) {
    return _databaseService.safeWrite((isar) async {
      await isar.providerDiagnosticsEntitys.put(
        ProviderDiagnosticsEntity.fromModel(diagnostics),
      );
    });
  }

  Future<Result<List<ProviderDiagnostics>>> getDiagnostics() {
    return _databaseService.safeRead((isar) async {
      final items = await isar.providerDiagnosticsEntitys.where().findAll();
      return items.map((item) => item.toModel()).toList();
    });
  }
}
