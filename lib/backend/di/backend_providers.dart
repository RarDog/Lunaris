import 'package:connectivity_plus/connectivity_plus.dart';
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
import '../repositories/collection_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/post_repository.dart';
import '../repositories/provider_repository.dart';
import '../repositories/search_repository.dart';
import '../repositories/viewed_post_repository.dart';
import '../services/collection_service.dart';
import '../services/download_service.dart';
import '../services/download_manager_service.dart';
import '../services/favorite_service.dart';
import '../services/feed_service.dart';
import '../services/provider_check_service.dart';
import '../services/search_service.dart';
import '../services/settings_service.dart';
import '../services/viewed_history_service.dart';

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

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(
    ref.watch(searchRepositoryProvider),
    ref.watch(providerManagerProvider),
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

final downloadManagerServiceProvider = Provider<DownloadManagerService>((ref) {
  return DownloadManagerService(ref.watch(downloadServiceProvider));
});

final downloadTasksProvider = StreamProvider<List<DownloadTask>>((ref) {
  final manager = ref.watch(downloadManagerServiceProvider);
  return manager.stream;
});
