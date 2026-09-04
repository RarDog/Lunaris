import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/favorite_artist_item.dart';
import 'package:gel_rule_app/backend/models/pawchive_account.dart';
import 'package:gel_rule_app/backend/services/pawchive_sync_service.dart';
import 'package:gel_rule_app/backend/services/settings_service.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<dynamic>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('FavoriteArtistItem Tests', () {
    test('roundtrip serialization and key generation', () {
      const item = FavoriteArtistItem(
        id: '12345',
        service: 'fanbox',
        providerId: 'pawchive',
        name: 'CoolArtist',
        avatarUrl: 'https://pawchive.pw/icons/fanbox/12345',
      );

      expect(item.key, equals('pawchive:fanbox:12345'));
      expect(item.isEmpty, isFalse);

      final json = item.toJson();
      final restored = FavoriteArtistItem.fromJson(json);
      expect(restored.key, equals(item.key));
      expect(restored.name, equals('CoolArtist'));
      expect(restored.avatarUrl, equals('https://pawchive.pw/icons/fanbox/12345'));
      expect(restored == item, isTrue);
    });

    test('empty factory behaves correctly', () {
      const empty = FavoriteArtistItem.empty();
      expect(empty.isEmpty, isTrue);
      expect(empty.key, equals('::'));
    });
  });

  group('PawchiveAccount Tests', () {
    test('roundtrip serialization and copyWith', () {
      final now = DateTime(2026, 9, 4, 12, 0, 0);
      final account = PawchiveAccount(
        id: 'tester',
        username: 'Tester',
        sessionCookie: 'eySessionToken123',
        baseUrl: 'https://pawchive.pw',
        createdAt: now,
        lastSyncedAt: now,
        isActive: true,
        syncedArtistsCount: 15,
      );

      final json = account.toJson();
      final restored = PawchiveAccount.fromJson(json);

      expect(restored.id, equals('tester'));
      expect(restored.username, equals('Tester'));
      expect(restored.sessionCookie, equals('eySessionToken123'));
      expect(restored.isActive, isTrue);
      expect(restored.syncedArtistsCount, equals(15));
      expect(restored == account, isTrue);

      final updated = account.copyWith(isActive: false, syncedArtistsCount: 20);
      expect(updated.isActive, isFalse);
      expect(updated.syncedArtistsCount, equals(20));
      expect(updated.id, equals('tester'));
    });
  });

  group('AppSettings Pawchive integration tests', () {
    test('serializes and parses pawchive accounts correctly', () {
      final acc1 = PawchiveAccount(
        id: 'user1',
        username: 'User1',
        sessionCookie: 'token1',
        createdAt: DateTime(2026, 9, 1),
        isActive: true,
        syncedArtistsCount: 5,
      );
      final acc2 = PawchiveAccount(
        id: 'user2',
        username: 'User2',
        sessionCookie: 'token2',
        createdAt: DateTime(2026, 9, 2),
        isActive: false,
        syncedArtistsCount: 10,
      );

      final settings = AppSettings.defaults.copyWith(
        pawchiveAccounts: [
          jsonEncode(acc1.toJson()),
          jsonEncode(acc2.toJson()),
        ],
      );

      expect(settings.parsedPawchiveAccounts.length, equals(2));
      expect(settings.activePawchiveAccount?.id, equals('user1'));

      final json = settings.toJson();
      final restored = AppSettings.fromJson(json);
      expect(restored.parsedPawchiveAccounts.length, equals(2));
      expect(restored.activePawchiveAccount?.username, equals('User1'));
    });
  });

  group('PawchiveSyncService Tests', () {
    test('fetchRemoteFavoriteArtists parses server response correctly', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        if (options.path.endsWith('/account/favorites') &&
            options.queryParameters['type'] == 'artist') {
          final cookie = options.headers['Cookie'] as String?;
          expect(cookie, contains('session=test_cookie_123'));

          final payload = jsonEncode([
            {
              'id': '98765',
              'service': 'fanbox',
              'name': 'AlphaCreator',
              'updated': '2026-09-04T10:00:00.000Z',
            },
            {
              'id': '43210',
              'service': 'patreon',
              'name': 'BetaCreator',
              'updated': '2026-09-03T15:00:00.000Z',
            },
          ]);

          return ResponseBody.fromString(
            payload,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not found', 404);
      });

      final service = PawchiveSyncService(dio: dio);
      final items = await service.fetchRemoteFavoriteArtists(
        baseUrl: 'https://pawchive.pw',
        sessionCookie: 'session=test_cookie_123;',
      );

      expect(items.length, equals(2));
      expect(items[0].id, equals('98765'));
      expect(items[0].service, equals('fanbox'));
      expect(items[0].name, equals('AlphaCreator'));
      expect(items[0].avatarUrl, equals('https://pawchive.pw/icons/fanbox/98765'));

      expect(items[1].id, equals('43210'));
      expect(items[1].service, equals('patreon'));
      expect(items[1].name, equals('BetaCreator'));
    });

    test('syncAccountFavorites merges remote artists into AppSettings', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        final payload = jsonEncode([
          {
            'id': 'remote_1',
            'service': 'fanbox',
            'name': 'RemoteArtistOne',
          },
          {
            'id': 'existing_local',
            'service': 'patreon',
            'name': 'AlreadyPresent',
          },
        ]);
        return ResponseBody.fromString(
          payload,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = PawchiveSyncService(dio: dio);

      const existingItem = FavoriteArtistItem(
        id: 'existing_local',
        service: 'patreon',
        providerId: 'pawchive',
        name: 'AlreadyPresent',
      );

      final initialSettings = AppSettings.defaults.copyWith(
        favoriteArtists: [jsonEncode(existingItem.toJson())],
      );

      final account = PawchiveAccount(
        id: 'myuser',
        username: 'myuser',
        sessionCookie: 'cookie123',
        createdAt: DateTime.now(),
      );

      final result = await service.syncAccountFavorites(
        account: account,
        settings: initialSettings,
      );

      expect(result.isSuccess, isTrue);
      expect(result.totalSyncedCount, equals(2));
      expect(result.newlyAddedToLocal, equals(1)); // remote_1 added, existing_local skipped
      expect(result.updatedSettings.favoriteArtists.length, equals(2));
    });

    test('toggleRemoteFavorite sends POST and DELETE successfully', () async {
      var lastMethod = '';
      var lastPath = '';

      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        lastMethod = options.method;
        lastPath = options.path;
        return ResponseBody.fromString('ok', 200);
      });

      final service = PawchiveSyncService(dio: dio);
      final account = PawchiveAccount(
        id: 'user1',
        username: 'user1',
        sessionCookie: 'session=abc',
        createdAt: DateTime.now(),
      );

      final addResult = await service.toggleRemoteFavorite(
        account: account,
        service: 'fanbox',
        artistId: '12345',
        isFavorite: true,
      );
      expect(addResult, isTrue);
      expect(lastMethod, equals('POST'));
      expect(lastPath, equals('https://pawchive.pw/api/v1/favorites/creator/fanbox/12345'));

      final removeResult = await service.toggleRemoteFavorite(
        account: account,
        service: 'fanbox',
        artistId: '12345',
        isFavorite: false,
      );
      expect(removeResult, isTrue);
      expect(lastMethod, equals('DELETE'));
      expect(lastPath, equals('https://pawchive.pw/api/v1/favorites/creator/fanbox/12345'));
    });

    test('pushLocalFavoritesToAccount exports local artists to Pawchive', () async {
      final postedPaths = <String>[];
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        if (options.path.endsWith('/api/v1/account/favorites')) {
          final payload = jsonEncode([
            {
              'id': 'already_remote_1',
              'service': 'fanbox',
              'name': 'AlreadyRemote',
            },
          ]);
          return ResponseBody.fromString(
            payload,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.method == 'POST' &&
            options.path.contains('/api/v1/favorites/creator/')) {
          postedPaths.add(options.path);
          return ResponseBody.fromString('ok', 204);
        }
        return ResponseBody.fromString('Not found', 404);
      });

      final service = PawchiveSyncService(dio: dio);

      const itemAlreadyRemote = FavoriteArtistItem(
        id: 'already_remote_1',
        service: 'fanbox',
        providerId: 'pawchive',
        name: 'AlreadyRemote',
      );
      const itemToUpload1 = FavoriteArtistItem(
        id: 'local_creator_99',
        service: 'patreon',
        providerId: 'kemono',
        name: 'LocalPatreonCreator',
      );
      const itemToUpload2 = FavoriteArtistItem(
        id: 'local_creator_88',
        service: 'subscribestar',
        providerId: 'coomer',
        name: 'LocalSubscribeStarCreator',
      );

      final settings = AppSettings.defaults.copyWith(
        favoriteArtists: [
          jsonEncode(itemAlreadyRemote.toJson()),
          jsonEncode(itemToUpload1.toJson()),
          jsonEncode(itemToUpload2.toJson()),
        ],
      );

      final account = PawchiveAccount(
        id: 'myacc',
        username: 'myacc',
        sessionCookie: 'session=123',
        createdAt: DateTime.now(),
      );

      final pushResult = await service.pushLocalFavoritesToAccount(
        account: account,
        settings: settings,
      );

      expect(pushResult.isSuccess, isTrue);
      expect(pushResult.pushedCount, equals(2));
      expect(pushResult.totalLocalCandidates, equals(3));
      expect(pushResult.totalRemoteCount, equals(3)); // 1 existing + 2 pushed
      expect(postedPaths.length, equals(2));
      expect(postedPaths[0], contains('/api/v1/favorites/creator/patreon/local_creator_99'));
      expect(postedPaths[1], contains('/api/v1/favorites/creator/subscribestar/local_creator_88'));
    });
  });
}
