import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/app/app.dart';
import 'package:gel_rule_app/backend/backend.dart';
import 'package:gel_rule_app/features/collections/presentation/collections_controller.dart';
import 'package:gel_rule_app/features/collections/presentation/collections_screen.dart';
import 'package:gel_rule_app/features/favorites/presentation/favorites_controller.dart';
import 'package:gel_rule_app/features/favorites/presentation/favorites_screen.dart';
import 'package:gel_rule_app/features/favorites/presentation/favorites_state.dart';
import 'package:gel_rule_app/features/search/presentation/search_controller.dart'
    as search_feature;
import 'package:gel_rule_app/features/search/presentation/search_screen.dart';
import 'package:gel_rule_app/features/search/presentation/search_state.dart';
import 'package:gel_rule_app/features/viewed/presentation/viewed_controller.dart';
import 'package:gel_rule_app/features/viewed/presentation/viewed_screen.dart';

Post _samplePost({
  required String id,
  String providerId = 'danbooru',
  String providerName = 'Danbooru',
  List<String> tags = const ['tag1', 'artist:test_artist'],
  String fileType = 'jpg',
}) {
  return Post(
    id: id,
    providerId: providerId,
    providerName: providerName,
    previewUrl: 'https://example.com/$id.jpg',
    sampleUrl: 'https://example.com/$id.jpg',
    fileUrl: 'https://example.com/$id.jpg',
    tags: tags,
    rating: 'safe',
    width: 800,
    height: 600,
    createdAt: DateTime.now(),
    fileType: fileType,
    score: 42,
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('FavoritesScreen renders segments, counters and filter chips',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final post = _samplePost(id: '1');
    final post2 = _samplePost(
        id: '2', fileType: 'mp4', tags: ['artist:animator', 'video']);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesControllerProvider.overrideWith(
            () => _FakeFavoritesController([post, post2]),
          ),
          appSettingsProvider.overrideWith(
            (ref) => AppSettings.defaults.copyWith(languageCode: 'ru'),
          ),
          downloadedMediaByKeysProvider([post.cacheKey, post2.cacheKey])
              .overrideWith((ref) => <String, DownloadedMedia>{}),
        ],
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify segmented button labels with live counts
    expect(find.text('Все (2)'), findsOneWidget);
    expect(find.text('Офлайн (0)'), findsOneWidget);
    expect(find.text('Авторы (2)'), findsOneWidget);

    // Verify media filter chips
    expect(find.text('Все'), findsWidgets);
    expect(find.text('Видео'), findsOneWidget);
    expect(find.text('Фото'), findsOneWidget);

    // Switch to Artists tab
    await tester.tap(find.text('Авторы (2)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('test_artist'), findsOneWidget);
    expect(find.text('animator'), findsOneWidget);
  });

  testWidgets('ViewedScreen renders timeline and switches view mode',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final post = _samplePost(id: '10', tags: ['landscape', 'sunset']);
    final group = ViewedTimelineGroup(
      label: 'Today',
      items: [
        ViewedPostEntry(post: post, viewedAt: DateTime.now()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          viewedControllerProvider.overrideWith(
            () => _FakeViewedController([group]),
          ),
          favoriteKeysProvider.overrideWith(
            (ref) => <String>{},
          ),
          appSettingsProvider.overrideWith(
            (ref) => AppSettings.defaults.copyWith(languageCode: 'ru'),
          ),
        ],
        child: const MaterialApp(
          home: ViewedScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify timeline group
    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('landscape sunset'), findsOneWidget);

    // Switch to Grid mode
    final gridBtn = find.byIcon(Icons.grid_view_rounded);
    expect(gridBtn, findsOneWidget);
    await tester.tap(gridBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Now icon should switch to list mode
    expect(find.byIcon(Icons.view_agenda_rounded), findsOneWidget);
  });

  testWidgets(
      'CollectionsScreen renders collection cards and new collection button',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final collection = Collection(
      id: 'c1',
      name: 'Cyberpunk Art',
      description: 'Futuristic neon cities',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionsControllerProvider.overrideWith(
            () => _FakeCollectionsController([collection]),
          ),
          collectionPostsProvider('c1').overrideWith(
            (ref) => Future.value([_samplePost(id: '1')]),
          ),
          appSettingsProvider.overrideWith(
            (ref) => AppSettings.defaults.copyWith(languageCode: 'ru'),
          ),
        ],
        child: const MaterialApp(
          home: CollectionsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Cyberpunk Art'), findsOneWidget);
    expect(find.text('Futuristic neon cities'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets(
      'SearchScreen renders hero search bar, quick chips, and categories',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          search_feature.searchControllerProvider.overrideWith(
            () => _FakeSearchController([
              SearchHistory(
                id: 'h1',
                query: 'genshin_impact',
                tags: const ['genshin_impact'],
                searchedAt: DateTime.now(),
                resultCount: 1500,
              ),
            ]),
          ),
          appSettingsProvider.overrideWith(
            (ref) => AppSettings.defaults.copyWith(languageCode: 'ru'),
          ),
        ],
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Search Bar and Quick Operator Chips
    expect(find.text('type:video'), findsOneWidget);
    expect(find.text('rating:safe'), findsOneWidget);

    // Verify Recent Searches chip
    expect(find.text('genshin_impact'), findsOneWidget);

    // Verify Popular Categories
    expect(find.text('Тематика'), findsOneWidget);
    expect(find.text('Персонажи и детали'), findsOneWidget);
    expect(find.text('Провайдеры'), findsOneWidget);
  });
}

class _FakeFavoritesController extends FavoritesController {
  _FakeFavoritesController(this._posts);

  final List<Post> _posts;

  @override
  Future<FavoritesState> build() async {
    return FavoritesState(posts: _posts);
  }
}

class _FakeViewedController extends ViewedController {
  _FakeViewedController(this._groups);

  final List<ViewedTimelineGroup> _groups;

  @override
  Future<List<ViewedTimelineGroup>> build() async => _groups;
}

class _FakeCollectionsController extends CollectionsController {
  _FakeCollectionsController(this._collections);

  final List<Collection> _collections;

  @override
  Future<List<Collection>> build() async => _collections;
}

class _FakeSearchController extends search_feature.SearchController {
  _FakeSearchController(this._history);

  final List<SearchHistory> _history;

  @override
  Future<SearchState> build() async {
    return SearchState(
      recent: _history,
    );
  }
}
