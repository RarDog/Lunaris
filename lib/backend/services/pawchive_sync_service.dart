import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/http/dio_client.dart';
import '../models/favorite_artist_item.dart';
import '../models/pawchive_account.dart';
import 'settings_service.dart';

final pawchiveSyncServiceProvider = Provider<PawchiveSyncService>((ref) {
  return PawchiveSyncService(dio: DioClient().dio);
});

class PawchiveSyncResult {
  const PawchiveSyncResult({
    required this.updatedSettings,
    required this.newlyAddedToLocal,
    required this.totalSyncedCount,
    this.pushedToRemoteCount = 0,
    this.errorMessage,
  });

  final AppSettings updatedSettings;
  final int newlyAddedToLocal;
  final int totalSyncedCount;
  final int pushedToRemoteCount;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}

class PawchivePushResult {
  const PawchivePushResult({
    required this.pushedCount,
    required this.totalRemoteCount,
    required this.totalLocalCandidates,
    this.updatedSettings,
    this.errorMessage,
  });

  final int pushedCount;
  final int totalRemoteCount;
  final int totalLocalCandidates;
  final AppSettings? updatedSettings;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}

class PawchiveSyncService {
  PawchiveSyncService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static String _normalizeCookie(String rawCookie) {
    var c = rawCookie.trim();
    if (c.startsWith('session=')) {
      c = c.substring('session='.length);
    }
    // strip semicolons if trailing
    final semiIdx = c.indexOf(';');
    if (semiIdx != -1) {
      c = c.substring(0, semiIdx);
    }
    return c.trim();
  }

  /// Logs into Pawchive with username & password, returns new PawchiveAccount on success.
  Future<PawchiveAccount> loginWithCredentials({
    required String username,
    required String password,
    String baseUrl = 'https://pawchive.pw',
  }) async {
    final cleanUser = username.trim();
    final cleanPass = password.trim();
    if (cleanUser.isEmpty || cleanPass.isEmpty) {
      throw ArgumentError('Логин и пароль не могут быть пустыми');
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    try {
      final response = await _dio.post<dynamic>(
        '$normalizedBase/account/login',
        data: {
          'username': cleanUser,
          'password': cleanPass,
          'location': '/artists',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
          headers: const {
            'User-Agent': 'Prisma/2.0.1 Flutter local booru browser',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );

      final redirectLocation = response.headers.value('location') ?? '';
      final setCookies = response.headers['set-cookie'] ?? const [];

      String? sessionValue;
      for (final cookie in setCookies) {
        final match = RegExp(r'session=([^;]+)').firstMatch(cookie);
        if (match != null) {
          sessionValue = match.group(1);
          break;
        }
      }

      if (sessionValue == null || sessionValue.isEmpty) {
        throw StateError('Не удалось получить сессию. Проверьте данные для входа.');
      }

      // Check if redirect points back to login with flash error
      if (redirectLocation.contains('/account/login') ||
          redirectLocation.contains('/login')) {
        throw StateError('Неверный логин или пароль');
      }

      // Check for flash errors in session cookie if present
      try {
        final dotIdx = sessionValue.indexOf('.');
        final payloadBase64 =
            dotIdx != -1 ? sessionValue.substring(0, dotIdx) : sessionValue;
        final normalizedB64 = base64Url.normalize(payloadBase64);
        final decoded = utf8.decode(base64Url.decode(normalizedB64));
        if (decoded.contains('is incorrect') || decoded.contains('_flashes')) {
          throw StateError('Неверный логин или пароль');
        }
      } catch (e) {
        if (e is StateError) rethrow;
      }

      // Verify session and fetch initial artists
      final remoteArtists = await fetchRemoteFavoriteArtists(
        baseUrl: normalizedBase,
        sessionCookie: sessionValue,
      );

      return PawchiveAccount(
        id: cleanUser.toLowerCase(),
        username: cleanUser,
        sessionCookie: sessionValue,
        baseUrl: normalizedBase,
        createdAt: DateTime.now(),
        lastSyncedAt: DateTime.now(),
        isActive: true,
        syncedArtistsCount: remoteArtists.length,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        throw StateError('Неверный логин или пароль');
      } else if (code != null) {
        throw StateError('Ошибка сервера Pawchive (HTTP $code)');
      } else {
        throw StateError('Ошибка сети: ${e.message ?? e.type.name}');
      }
    } catch (e) {
      if (e is StateError || e is ArgumentError) rethrow;
      throw StateError('Ошибка входа в Pawchive: $e');
    }
  }

  /// Validates session cookie directly and creates PawchiveAccount.
  Future<PawchiveAccount> loginWithSession({
    required String sessionCookie,
    required String username,
    String baseUrl = 'https://pawchive.pw',
  }) async {
    final cleanUser = username.trim().isEmpty ? 'Pawchive User' : username.trim();
    final cleanCookie = _normalizeCookie(sessionCookie);
    if (cleanCookie.isEmpty) {
      throw ArgumentError('Сессионная кука не может быть пустой');
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    try {
      final remoteArtists = await fetchRemoteFavoriteArtists(
        baseUrl: normalizedBase,
        sessionCookie: cleanCookie,
      );

      return PawchiveAccount(
        id: cleanUser.toLowerCase(),
        username: cleanUser,
        sessionCookie: cleanCookie,
        baseUrl: normalizedBase,
        createdAt: DateTime.now(),
        lastSyncedAt: DateTime.now(),
        isActive: true,
        syncedArtistsCount: remoteArtists.length,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        throw StateError('Сессия недействительна или истекла');
      } else if (code != null) {
        throw StateError('Ошибка сервера Pawchive (HTTP $code)');
      } else {
        throw StateError('Ошибка сети: ${e.message ?? e.type.name}');
      }
    } catch (e) {
      if (e is StateError || e is ArgumentError) rethrow;
      throw StateError('Сессия недействительна или истекла: $e');
    }
  }

  /// Fetches favorite creators from Pawchive account.
  Future<List<FavoriteArtistItem>> fetchRemoteFavoriteArtists({
    required String baseUrl,
    required String sessionCookie,
  }) async {
    final cleanCookie = _normalizeCookie(sessionCookie);
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final response = await _dio.get<dynamic>(
      '$normalizedBase/api/v1/account/favorites',
      queryParameters: {'type': 'artist'},
      options: Options(
        headers: {
          'Cookie': 'session=$cleanCookie',
          'Accept': 'application/json',
          'User-Agent': 'Prisma/2.0.1 Flutter local booru browser',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError('Сессия истекла или недействительна');
    }
    if (response.statusCode != 200) {
      throw StateError('Ошибка сервера Pawchive (HTTP ${response.statusCode})');
    }

    final data = response.data;
    if (data is! List) return const [];

    final list = <FavoriteArtistItem>[];
    for (final raw in data) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final id = (item['id'] ?? '').toString();
      final service = (item['service'] ?? '').toString();
      final name = (item['name'] ?? id).toString();
      if (id.isEmpty || service.isEmpty) continue;

      final avatarUrl = '$normalizedBase/icons/$service/$id';
      list.add(FavoriteArtistItem(
        id: id,
        service: service,
        providerId: 'pawchive',
        name: name,
        avatarUrl: avatarUrl,
      ));
    }
    return list;
  }

  /// Synchronizes a specific Pawchive account with current local AppSettings.
  /// If [pushLocalPawchiveArtists] is true (or [settings.pawchiveBidirectionalSync] is enabled),
  /// local favorites are also pushed to the Pawchive server.
  Future<PawchiveSyncResult> syncAccountFavorites({
    required PawchiveAccount account,
    required AppSettings settings,
    bool? pushLocalPawchiveArtists,
  }) async {
    try {
      final remoteArtists = await fetchRemoteFavoriteArtists(
        baseUrl: account.baseUrl,
        sessionCookie: account.sessionCookie,
      );

      final currentFavorites = List<String>.from(settings.favoriteArtists);
      final existingKeys = <String>{};
      final existingServiceId = <String>{};
      for (final raw in currentFavorites) {
        try {
          final parsed = FavoriteArtistItem.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
          existingKeys.add(parsed.key);
          if (parsed.service.isNotEmpty && parsed.id.isNotEmpty) {
            existingServiceId.add('${parsed.service}:${parsed.id}'.toLowerCase());
          }
        } catch (_) {}
      }

      var addedCount = 0;
      for (final artist in remoteArtists) {
        final pair = '${artist.service}:${artist.id}'.toLowerCase();
        if (!existingKeys.contains(artist.key) && !existingServiceId.contains(pair)) {
          currentFavorites.insert(0, jsonEncode(artist.toJson()));
          existingKeys.add(artist.key);
          existingServiceId.add(pair);
          addedCount++;
        }
      }

      var pushedCount = 0;
      final shouldPush =
          pushLocalPawchiveArtists ?? settings.pawchiveBidirectionalSync;
      if (shouldPush) {
        final remotePairSet = remoteArtists
            .map((a) => '${a.service}:${a.id}'.toLowerCase())
            .toSet();

        for (final raw in currentFavorites) {
          try {
            final parsed = FavoriteArtistItem.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            );
            if (parsed.service.isNotEmpty && parsed.id.isNotEmpty) {
              final pair = '${parsed.service}:${parsed.id}'.toLowerCase();
              if (!remotePairSet.contains(pair)) {
                final ok = await toggleRemoteFavorite(
                  account: account,
                  service: parsed.service,
                  artistId: parsed.id,
                  isFavorite: true,
                );
                if (ok) {
                  pushedCount++;
                  remotePairSet.add(pair);
                }
              }
            }
          } catch (_) {}
        }
      }

      // Update account sync stats in settings
      final updatedAccount = account.copyWith(
        lastSyncedAt: DateTime.now(),
        syncedArtistsCount: remoteArtists.length + pushedCount,
      );

      final updatedAccountsList = settings.parsedPawchiveAccounts.map((a) {
        return a.id == updatedAccount.id ? updatedAccount : a;
      }).toList();

      final newSettings = settings.copyWith(
        favoriteArtists: currentFavorites,
        pawchiveAccounts:
            updatedAccountsList.map((a) => jsonEncode(a.toJson())).toList(),
      );

      return PawchiveSyncResult(
        updatedSettings: newSettings,
        newlyAddedToLocal: addedCount,
        pushedToRemoteCount: pushedCount,
        totalSyncedCount: remoteArtists.length + pushedCount,
      );
    } catch (e) {
      return PawchiveSyncResult(
        updatedSettings: settings,
        newlyAddedToLocal: 0,
        pushedToRemoteCount: 0,
        totalSyncedCount: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Explicitly pushes all local favorite artists into a specified Pawchive account.
  Future<PawchivePushResult> pushLocalFavoritesToAccount({
    required PawchiveAccount account,
    required AppSettings settings,
  }) async {
    try {
      final remoteArtists = await fetchRemoteFavoriteArtists(
        baseUrl: account.baseUrl,
        sessionCookie: account.sessionCookie,
      );

      final remotePairSet = remoteArtists
          .map((a) => '${a.service}:${a.id}'.toLowerCase())
          .toSet();

      var pushedCount = 0;
      var totalLocalCandidates = 0;

      for (final raw in settings.favoriteArtists) {
        try {
          final parsed = FavoriteArtistItem.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
          if (parsed.service.isNotEmpty && parsed.id.isNotEmpty) {
            totalLocalCandidates++;
            final pair = '${parsed.service}:${parsed.id}'.toLowerCase();
            if (!remotePairSet.contains(pair)) {
              final ok = await toggleRemoteFavorite(
                account: account,
                service: parsed.service,
                artistId: parsed.id,
                isFavorite: true,
              );
              if (ok) {
                pushedCount++;
                remotePairSet.add(pair);
              }
            }
          }
        } catch (_) {}
      }

      final updatedAccount = account.copyWith(
        lastSyncedAt: DateTime.now(),
        syncedArtistsCount: remoteArtists.length + pushedCount,
      );

      final updatedAccountsList = settings.parsedPawchiveAccounts.map((a) {
        return a.id == updatedAccount.id ? updatedAccount : a;
      }).toList();

      final newSettings = settings.copyWith(
        pawchiveAccounts:
            updatedAccountsList.map((a) => jsonEncode(a.toJson())).toList(),
      );

      return PawchivePushResult(
        pushedCount: pushedCount,
        totalRemoteCount: remoteArtists.length + pushedCount,
        totalLocalCandidates: totalLocalCandidates,
        updatedSettings: newSettings,
      );
    } catch (e) {
      return PawchivePushResult(
        pushedCount: 0,
        totalRemoteCount: 0,
        totalLocalCandidates: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Synchronizes ALL connected Pawchive accounts with local AppSettings.
  Future<PawchiveSyncResult> syncAllAccounts({
    required AppSettings settings,
    bool? pushLocalArtists,
  }) async {
    final accounts = settings.parsedPawchiveAccounts;
    if (accounts.isEmpty) {
      return PawchiveSyncResult(
        updatedSettings: settings,
        newlyAddedToLocal: 0,
        pushedToRemoteCount: 0,
        totalSyncedCount: 0,
        errorMessage: 'Нет добавленных аккаунтов Pawchive',
      );
    }

    final doPush = pushLocalArtists ?? settings.pawchiveBidirectionalSync;
    var runningSettings = settings;
    var totalAdded = 0;
    var totalSynced = 0;
    var totalPushed = 0;
    String? firstError;

    for (final account in accounts) {
      final res = await syncAccountFavorites(
        account: account,
        settings: runningSettings,
        pushLocalPawchiveArtists: doPush,
      );
      if (res.isSuccess) {
        runningSettings = res.updatedSettings;
        totalAdded += res.newlyAddedToLocal;
        totalPushed += res.pushedToRemoteCount;
        totalSynced += res.totalSyncedCount;
      } else {
        firstError ??= res.errorMessage;
      }
    }

    return PawchiveSyncResult(
      updatedSettings: runningSettings,
      newlyAddedToLocal: totalAdded,
      pushedToRemoteCount: totalPushed,
      totalSyncedCount: totalSynced,
      errorMessage: firstError,
    );
  }

  /// Toggles favorite creator on Pawchive server (POST or DELETE).
  Future<bool> toggleRemoteFavorite({
    required PawchiveAccount account,
    required String service,
    required String artistId,
    required bool isFavorite,
  }) async {
    final cleanCookie = _normalizeCookie(account.sessionCookie);
    final normalizedBase = account.baseUrl.endsWith('/')
        ? account.baseUrl.substring(0, account.baseUrl.length - 1)
        : account.baseUrl;

    final path = '$normalizedBase/api/v1/favorites/creator/$service/$artistId';
    final options = Options(
      headers: {
        'Cookie': 'session=$cleanCookie',
        'User-Agent': 'Prisma/2.0.1 Flutter local booru browser',
      },
      validateStatus: (status) =>
          status != null && (status == 200 || status == 201 || status == 204),
    );

    try {
      if (isFavorite) {
        final response = await _dio.post<dynamic>(path, options: options);
        return response.statusCode != null && response.statusCode! < 300;
      } else {
        final response = await _dio.delete<dynamic>(path, options: options);
        return response.statusCode != null && response.statusCode! < 300;
      }
    } catch (_) {
      return false;
    }
  }
}
