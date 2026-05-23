# GelRuleApp

GelRuleApp is a single Flutter monolith for browsing booru/gelbooru/rule34-like providers with a Pinterest-style feed. It does not start or require a separate backend server. Provider access, caching, favorites, collections, search history, settings, and health checks all run locally inside the Flutter app.

## Stack

- Dart and Flutter
- Riverpod for dependency injection
- Dio for provider HTTP APIs
- Isar for local storage
- connectivity_plus for network state
- build_runner with Isar/freezed/json_serializable dependencies available for generated code workflows
- go_router for navigation
- cached_network_image and flutter_staggered_grid_view for the Pinterest-style feed
- media_kit for video posts

## Structure

- `lib/core/http`: Dio setup, retry/backoff, network info
- `lib/core/database`: Isar database and entity mappings
- `lib/core/cache`: metadata cache helpers
- `lib/core/errors`: app exceptions and failures
- `lib/core/utils`: `Result<T>` and logging
- `lib/backend/models`: domain models
- `lib/backend/providers`: provider interface, concrete providers, factory, manager
- `lib/backend/repositories`: local persistence access
- `lib/backend/services`: app-facing service layer
- `lib/backend/di`: Riverpod providers
- `lib/app`: app shell, router, theme, responsive helpers
- `lib/shared/widgets`: reusable UI pieces
- `lib/features`: feed, post details, search, favorites, collections, providers, settings

## Frontend Routes

- `/`: masonry feed
- `/search`: recent searches and autocomplete
- `/post/:providerId/:postId`: post details
- `/favorites`: favorite posts
- `/collections`: boards
- `/collections/:collectionId`: posts inside a collection
- `/providers`: provider management
- `/providers/new`: provider form for create/edit
- `/providers/check`: provider health checks
- `/settings`: app settings

## Frontend And Backend Integration

The UI calls backend services through Riverpod providers from `lib/backend/di/backend_providers.dart`.

- `FeedController` calls `FeedService`, `SearchService`, and `ProviderManager`.
- `PostDetailsScreen` uses cached post metadata first, then `ProviderManager.getPost`.
- `PostCard` and details actions call `FavoriteService` and `CollectionService`.
- Provider screens call `ProviderManager` and `ProviderCheckService`.
- Settings call `SettingsService` and `CacheService`.

Business logic stays in backend/core services. UI controllers only coordinate state and user actions.

## Providers

The MVP ships with seed configs for:

- Gelbooru: `https://gelbooru.com`
- Rule34: `https://api.rule34.xxx`
- Safebooru: `https://safebooru.org`

Providers implement:

```dart
abstract class ContentProvider {
  String get id;
  String get name;
  String get baseUrl;

  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
  });

  Future<Post?> getPost(String id);
  Future<ProviderHealth> checkHealth();
}
```

Gelbooru and Rule34 use the Gelbooru-compatible dapi endpoint:

```text
/index.php?page=dapi&s=post&q=index&json=1
```

Danbooru uses:

```text
/posts.json
```

All provider responses are normalized to `Post`.

## Adding A Provider

1. Add a mapper in `lib/backend/mappers`.
2. Implement `ContentProvider` in `lib/backend/providers`.
3. Register the `apiType` in `ProviderFactory`.
4. Save a `ContentProviderConfig` with `ProviderManager.addCustomProvider`.

For custom providers, MVP supports these `apiType` values:

- `gelbooru`
- `rule34`
- `danbooru`

Unsupported types return `ProviderUnavailableException` instead of crashing the app.

## ProviderManager

`ProviderManager` loads enabled provider configs from Isar, sorts them by `priority`, creates provider instances through `ProviderFactory`, checks health, and performs multi-provider search.

Search behavior:

- Offline providers are skipped based on saved health.
- A failed provider marks itself offline.
- Other providers continue returning posts.
- Results are combined into a single list.

## Health Checks

Use `ProviderCheckService`:

```dart
final health = await ref
    .read(providerCheckServiceProvider)
    .checkOne('gelbooru');

final all = await ref
    .read(providerCheckServiceProvider)
    .checkAll();
```

`checkAll()` runs in parallel with a concurrency limit of 3 and saves `ProviderHealth` in Isar.

## Using Services From Flutter UI

Initialize your app with Riverpod:

```dart
ProviderScope(
  child: MyApp(),
);
```

Load a feed:

```dart
final feed = ref.read(feedServiceProvider);
final result = await feed.refresh(
  tags: ['landscape'],
  rating: 'safe',
);
```

Infinite scroll:

```dart
final next = await ref.read(feedServiceProvider).loadNextPage(
  tags: ['landscape'],
);
```

Search history:

```dart
final search = ref.read(searchServiceProvider);
final tags = search.parseTags('cat cute');
await search.saveSearch('cat cute', 120);
final recent = await search.recentSearches();
```

Favorites:

```dart
await ref.read(favoriteServiceProvider).addFavorite(post);
final saved = await ref
    .read(favoriteServiceProvider)
    .isFavorite(post.id, post.providerId);
```

Collections:

```dart
final collection = await ref
    .read(collectionServiceProvider)
    .createCollection('Inspiration', 'Reference posts');

await ref
    .read(collectionServiceProvider)
    .addPostToCollection(collection.data.id, post);
```

Settings export/import:

```dart
final settings = ref.read(settingsServiceProvider);
final json = await settings.exportSettingsToJson();
await settings.importSettingsFromJson(json.data);
```

## Local Storage

Isar stores:

- provider configs
- provider health
- cached post metadata
- favorites
- collections
- collection-post links
- search history
- app settings

Post cache stores metadata only. It does not download or persist original media files.

## Safety Notes

- The app requests API metadata only.
- It does not bypass site limits or authentication.
- Dio uses a clear User-Agent.
- Retry is limited and uses exponential backoff.
- Provider failures are isolated so one offline provider does not break the feed.

## Development

Fetch dependencies:

```bash
flutter pub get
```

On Windows, Flutter plugins require Developer Mode for symlink support. If `flutter pub get` or desktop builds show a symlink warning, enable Developer Mode in Windows settings.

Generate Isar code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run tests:

```bash
flutter test
```

Run the app:

```bash
flutter run -d windows
flutter run -d linux
flutter run -d android
```

Build release artifacts:

```bash
flutter build windows
flutter build linux
flutter build apk
```

Notes:

- Windows builds require Windows Developer Mode when plugins are used.
- Linux builds must be run on a Linux host.
- Android builds require Android SDK and `ANDROID_HOME`.

## Adding A Screen

1. Add a route in `lib/app/router.dart`.
2. Add feature state/controller/screen under `lib/features/<name>/presentation`.
3. Use backend providers from `backend_providers.dart`; do not recreate Dio, Isar, or provider logic in UI code.
4. Add loading, error, empty, and success states.
