import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/content_provider_config.dart';
import 'package:gel_rule_app/backend/models/post.dart';
import 'package:gel_rule_app/backend/repositories/collection_repository.dart';
import 'package:gel_rule_app/backend/repositories/favorite_repository.dart';
import 'package:gel_rule_app/backend/repositories/post_repository.dart';
import 'package:gel_rule_app/backend/repositories/provider_repository.dart';
import 'package:gel_rule_app/backend/repositories/viewed_post_repository.dart';
import 'package:gel_rule_app/backend/services/collection_service.dart';
import 'package:gel_rule_app/backend/services/settings_service.dart';
import 'package:gel_rule_app/backend/services/viewed_history_service.dart';
import 'package:gel_rule_app/core/cache/cache_service.dart';
import 'package:gel_rule_app/core/database/app_database.dart';
import 'package:gel_rule_app/core/database/database_service.dart';
import 'package:gel_rule_app/core/utils/result.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late AppDatabase database;
  late DatabaseService databaseService;
  late PostRepository postRepository;
  late File copiedIsarDll;

  setUpAll(() async {
    if (Platform.isLinux) {
      await Isar.initializeIsarCore(
        libraries: {
          Abi.linuxX64:
              '${Directory.current.path}/third_party/isar_flutter_libs/linux/libisar.so',
        },
      );
    }
    copiedIsarDll =
        File('${Directory.current.path}${Platform.pathSeparator}isar.dll');
    if (Platform.isWindows && !copiedIsarDll.existsSync()) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      final source = File(
        '$localAppData\\Pub\\Cache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll',
      );
      if (source.existsSync()) {
        await source.copy(copiedIsarDll.path);
      }
    }
  });

  tearDownAll(() async {
    if (Platform.isWindows && copiedIsarDll.existsSync()) {
      // Windows keeps the loaded native library locked until the test process exits.
      // The project .gitignore excludes this copied test artifact.
    }
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('gel_rule_isar_test_');
    database = await AppDatabase.open(directory: directory.path);
    databaseService = DatabaseService(database);
    postRepository = PostRepository(databaseService);
  });

  tearDown(() async {
    await database.close();
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  });

  test('provider repository seeds default providers', () async {
    final repository = ProviderRepository(databaseService);

    await repository.ensureSeedProviders();
    final result = await repository.getProviders();
    final providers = (result as Success).data;

    expect(providers.map((provider) => provider.id), [
      'gelbooru',
      'rule34',
      'safebooru',
      'konachan',
      'yandere',
      'e621',
      'e926',
      'realbooru',
      'xbooru',
      'cosbooru',
      'kemono',
      'coomer',
    ]);
    expect(
      providers.singleWhere((provider) => provider.id == 'realbooru').enabled,
      isFalse,
    );
    expect(
      providers.singleWhere((provider) => provider.id == 'cosbooru').enabled,
      isTrue,
    );
    final xbooru = providers.singleWhere((provider) => provider.id == 'xbooru');
    expect(xbooru.enabled, isTrue);
    expect(xbooru.baseUrl, 'https://xbooru.com');
    expect(xbooru.apiType, 'gelbooru');
    final cosbooru =
        providers.singleWhere((provider) => provider.id == 'cosbooru');
    expect(cosbooru.baseUrl, 'https://cos.lycore.co');
    expect(cosbooru.apiType, 'danbooru');
    final kemono = providers.singleWhere((provider) => provider.id == 'kemono');
    final coomer = providers.singleWhere((provider) => provider.id == 'coomer');
    expect(kemono.enabled, isTrue);
    expect(kemono.apiType, 'kemono');
    expect(coomer.enabled, isFalse);
    expect(coomer.apiType, 'coomer');
  });

  test('provider repository migrates old CosBooru config', () async {
    final repository = ProviderRepository(databaseService);
    final now = DateTime(2026);
    await repository.saveProvider(ContentProviderConfig(
      id: 'cosbooru',
      name: 'CosBooru',
      baseUrl: 'https://cos.booru.nl',
      apiType: 'gelbooru',
      enabled: false,
      priority: 99,
      timeoutSeconds: 10,
      customHeaders: const {},
      createdAt: now,
      updatedAt: now,
    ));

    await repository.ensureSeedProviders();
    final providers = (await repository.getProviders() as Success).data;
    final cosbooru =
        providers.singleWhere((provider) => provider.id == 'cosbooru');

    expect(cosbooru.baseUrl, 'https://cos.lycore.co');
    expect(cosbooru.apiType, 'danbooru');
    expect(cosbooru.enabled, isTrue);
    expect(cosbooru.priority, 9);
  });

  test('settings saveEnabledProviders updates provider configs', () async {
    final providerRepository = ProviderRepository(databaseService);
    await providerRepository.ensureSeedProviders();
    final service = SettingsService(
      databaseService,
      providerRepository: providerRepository,
    );

    await service.saveEnabledProviders(['safebooru']);
    final providers = (await providerRepository.getProviders() as Success).data;

    expect(
        providers.singleWhere((provider) => provider.id == 'safebooru').enabled,
        isTrue);
    expect(
        providers.singleWhere((provider) => provider.id == 'gelbooru').enabled,
        isFalse);
    expect(providers.singleWhere((provider) => provider.id == 'rule34').enabled,
        isFalse);
  });

  test('favorite repository persists favorite and cached post metadata',
      () async {
    final repository = FavoriteRepository(databaseService, postRepository);
    final item = post('1');

    await repository.add(item);

    expect((await repository.exists('1', 'gelbooru') as Success).data, isTrue);
    expect(
        (await postRepository.getCachedPost('1', 'gelbooru') as Success)
            .data
            ?.id,
        '1');
  });

  test('collection service preserves createdAt on update and keeps cached post',
      () async {
    final repository = CollectionRepository(databaseService, postRepository);
    final service = CollectionService(repository);
    final created = await service.createCollection('A', 'old') as Success;
    final createdAt = created.data.createdAt;

    await service.updateCollection(created.data.id,
        name: 'B', description: 'new');
    final updated = (await service.getCollections() as Success).data.single;

    expect(updated.name, 'B');
    expect(updated.createdAt, createdAt);

    final item = post('2');
    await service.addPostToCollection(updated.id, item);
    await service.removePostFromCollection(
        updated.id, item.id, item.providerId);

    expect((await service.getCollectionPosts(updated.id) as Success).data,
        isEmpty);
    expect(
        (await postRepository.getCachedPost('2', 'gelbooru') as Success)
            .data
            ?.id,
        '2');
  });

  test('deleted collection stays deleted after repository reload', () async {
    final repository = CollectionRepository(databaseService, postRepository);
    final service = CollectionService(repository);
    final created = await service.createCollection('Temp', null) as Success;
    final item = post('collection-delete');

    await service.addPostToCollection(created.data.id, item);
    await service.deleteCollection(created.data.id);

    final reloadedService = CollectionService(
      CollectionRepository(databaseService, postRepository),
    );

    expect((await reloadedService.getCollections() as Success).data, isEmpty);
    expect(
      (await reloadedService.getCollectionPosts(created.data.id) as Success)
          .data,
      isEmpty,
    );
  });

  test('settings export keeps blacklist whitelist and smart rules', () async {
    final service = SettingsService(databaseService);
    await service.updateSettings(
      AppSettings.defaults.copyWith(
        blacklistedTags: ['blocked'],
        whitelistedTags: ['allowed'],
        smartBlacklistRules: ['provider:e621 score:<10'],
        hiddenPostKeys: ['provider:post'],
      ),
    );

    final exported = await service.exportSettingsToJson() as Success<String>;

    expect(exported.data, contains('"blacklistedTags"'));
    expect(exported.data, contains('"blocked"'));
    expect(exported.data, contains('"whitelistedTags"'));
    expect(exported.data, contains('"allowed"'));
    expect(exported.data, contains('"smartBlacklistRules"'));
    expect(exported.data, contains('provider:e621 score:<10'));
    expect(exported.data, contains('"hiddenPostKeys"'));
    expect(exported.data, contains('"provider:post"'));
  });

  test('cache service prunes to max item count', () async {
    final service = CacheService(databaseService);

    await service.cachePosts([post('1'), post('2'), post('3')], maxItems: 2);
    final cached = await service.getCachedPosts() as Success;

    expect(cached.data, hasLength(2));
  });

  test('viewed history persists keys and clears history', () async {
    final service = ViewedHistoryService(
      ViewedPostRepository(databaseService),
      postRepository,
    );
    final item = post('seen');

    await service.markViewed(item);
    expect((await service.isViewed(item.id, item.providerId) as Success).data,
        isTrue);
    expect((await service.getViewedKeys() as Success).data,
        contains(item.cacheKey));

    await service.clearHistory();
    expect((await service.getViewedKeys() as Success).data, isEmpty);
  });
}

Post post(String id) => Post(
      id: id,
      providerId: 'gelbooru',
      providerName: 'Gelbooru',
      previewUrl: 'https://example.test/$id-preview.jpg',
      sampleUrl: 'https://example.test/$id-sample.jpg',
      fileUrl: 'https://example.test/$id.jpg',
      tags: const ['tag'],
      rating: 'safe',
      width: 100,
      height: 100,
      createdAt: DateTime.now(),
      fileType: 'image',
      score: 1,
    );
