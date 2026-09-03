import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/cache_service.dart';
import '../../core/cache/image_cache_service.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/http/network_info.dart';
import '../../core/utils/result.dart';
import '../providers/provider_factory.dart';
import '../providers/provider_manager.dart';
import '../models/download_task.dart';
import '../models/downloaded_media.dart';
import '../models/post.dart';
import '../repositories/collection_repository.dart';
import '../repositories/downloaded_media_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/post_repository.dart';
import '../repositories/provider_repository.dart';
import '../repositories/search_repository.dart';
import '../repositories/viewed_post_repository.dart';
import '../services/collection_service.dart';
import '../services/download_service.dart';
import '../services/download_manager_service.dart';
import '../services/downloaded_media_service.dart';
import '../services/favorite_service.dart';
import '../services/feed_service.dart';
import '../services/provider_check_service.dart';
import '../services/search_service.dart';
import '../services/tag_cache_service.dart';
import '../services/settings_service.dart';
import '../services/update_service.dart';
import '../services/viewed_history_service.dart';
import '../services/backup_service.dart';

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final database = await AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final database = ref.watch(appDatabaseProvider).requireValue;
  return DatabaseService(database);
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(ref.watch(connectivityProvider));
});

final providerFactoryProvider = Provider<ProviderFactory>((ref) {
  return ProviderFactory();
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(databaseServiceProvider));
});

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return ProviderRepository(ref.watch(databaseServiceProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.watch(databaseServiceProvider));
});

final viewedPostRepositoryProvider = Provider<ViewedPostRepository>((ref) {
  return ViewedPostRepository(ref.watch(databaseServiceProvider));
});

final downloadedMediaRepositoryProvider =
    Provider<DownloadedMediaRepository>((ref) {
  return DownloadedMediaRepository(ref.watch(databaseServiceProvider));
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(
    ref.watch(databaseServiceProvider),
    ref.watch(postRepositoryProvider),
  );
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepository(
    ref.watch(databaseServiceProvider),
    ref.watch(postRepositoryProvider),
  );
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(ref.watch(databaseServiceProvider));
});

final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  return ImageCacheService();
});

final providerManagerProvider = Provider<ProviderManager>((ref) {
  return ProviderManager(
    ref.watch(providerRepositoryProvider),
    ref.watch(providerFactoryProvider),
  );
});

final feedServiceProvider = Provider<FeedService>((ref) {
  return FeedService(
    ref.watch(providerManagerProvider),
    ref.watch(cacheServiceProvider),
    ref.watch(settingsServiceProvider),
    ref.watch(viewedHistoryServiceProvider),
  );
});

final viewedHistoryServiceProvider = Provider<ViewedHistoryService>((ref) {
  return ViewedHistoryService(
    ref.watch(viewedPostRepositoryProvider),
    ref.watch(postRepositoryProvider),
  );
});

final viewedKeysProvider = FutureProvider<Set<String>>((ref) async {
  final result = await ref.watch(viewedHistoryServiceProvider).getViewedKeys();
  return result is Success<Set<String>> ? result.data : <String>{};
});

final tagCacheServiceProvider = Provider<TagCacheService>((ref) {
  final service = TagCacheService();
  unawaited(service.init());
  return service;
});

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(
    ref.watch(searchRepositoryProvider),
    ref.watch(providerManagerProvider),
    ref.watch(tagCacheServiceProvider),
  );
});

final providerCheckServiceProvider = Provider<ProviderCheckService>((ref) {
  return ProviderCheckService(
    ref.watch(providerRepositoryProvider),
    ref.watch(providerFactoryProvider),
    ref.watch(providerManagerProvider),
  );
});

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  return FavoriteService(
    ref.watch(favoriteRepositoryProvider),
    ref.watch(postRepositoryProvider),
  );
});

final collectionServiceProvider = Provider<CollectionService>((ref) {
  return CollectionService(ref.watch(collectionRepositoryProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(
    ref.watch(databaseServiceProvider),
    providerRepository: ref.watch(providerRepositoryProvider),
  );
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

final downloadedMediaServiceProvider = Provider<DownloadedMediaService>((ref) {
  return DownloadedMediaService(ref.watch(downloadedMediaRepositoryProvider));
});

final downloadManagerServiceProvider = Provider<DownloadManagerService>((ref) {
  return DownloadManagerService(
    ref.watch(downloadServiceProvider),
    downloadedMediaService: ref.watch(downloadedMediaServiceProvider),
    settingsService: ref.watch(settingsServiceProvider),
  );
});

final downloadedMediaByKeysProvider =
    FutureProvider.family<Map<String, DownloadedMedia>, Iterable<String>>(
        (ref, keys) async {
  final result =
      await ref.watch(downloadedMediaServiceProvider).allByKeys(keys);
  return result is Success<Map<String, DownloadedMedia>>
      ? result.data
      : const {};
});

final downloadedMediaByKeyProvider =
    FutureProvider.family<DownloadedMedia?, String>((ref, cacheKey) async {
  final result =
      await ref.watch(downloadedMediaServiceProvider).getByCacheKey(cacheKey);
  return result is Success<DownloadedMedia?> ? result.data : null;
});

final postMediaHeadersProvider =
    FutureProvider.family<Map<String, String>, Post>((ref, post) async {
  final result = await ref.watch(providerManagerProvider).getMediaHeaders(post);
  return result is Success<Map<String, String>> ? result.data : const {};
});

final downloadTasksProvider = StreamProvider<List<DownloadTask>>((ref) {
  final manager = ref.watch(downloadManagerServiceProvider);
  return manager.stream;
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(
    Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: const {
          'User-Agent': 'Lunaris/2.0.1 Flutter local booru browser',
          'Accept': 'application/json',
        },
      ),
    ),
    ref.watch(settingsServiceProvider),
  );
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(settingsServiceProvider));
});
