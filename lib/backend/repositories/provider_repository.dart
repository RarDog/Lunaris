import 'package:isar/isar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/result.dart';
import '../models/content_provider_config.dart';
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
    ];
  }

  Future<Result<void>> ensureSeedProviders() {
    return _databaseService.safeWrite((isar) async {
      final count = await isar.providerConfigEntitys.count();
      if (count > 0) return;
      await isar.providerConfigEntitys.putAll(
        seedProviders().map(ProviderConfigEntity.fromModel).toList(),
      );
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
}
