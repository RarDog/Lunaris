import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/http/dio_client.dart';
import '../di/backend_providers.dart';
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
    this.errorMessage,
  });

  final AppSettings updatedSettings;
  final int newlyAddedToLocal;
  final int totalSyncedCount;
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
            'User-Agent': 'Lunaris/2.0.1 Flutter local booru browser',
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
      if (redirectLocation.contains('/account/login')) {
        throw StateError('Неверный логин или пароль');
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
    } catch (e) {
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
      '$normalizedBase/account/favorites',
      queryParameters: {'type': 'artist'},
      options: Options(
        headers: {
          'Cookie': 'session=$cleanCookie',
          'Accept': 'application/json',
          'User-Agent': 'Lunaris/2.0.1 Flutter local booru browser',
        },
      ),
    );

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
  Future<PawchiveSyncResult> syncAccountFavorites({
    required PawchiveAccount account,
    required AppSettings settings,
    bool pushLocalPawchiveArtists = false,
  }) async {
    try {
      final remoteArtists = await fetchRemoteFavoriteArtists(
        baseUrl: account.baseUrl,
        sessionCookie: account.sessionCookie,
      );

      final currentFavorites = List<String>.from(settings.favoriteArtists);
      final existingKeys = <String>{};
      for (final raw in currentFavorites) {
        try {
          final parsed = FavoriteArtistItem.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
          existingKeys.add(parsed.key);
        } catch (_) {}
      }

      var addedCount = 0;
      for (final artist in remoteArtists) {
        if (!existingKeys.contains(artist.key)) {
          currentFavorites.insert(0, jsonEncode(artist.toJson()));
          existingKeys.add(artist.key);
          addedCount++;
        }
      }

      // Optionally push local Pawchive artists to remote
      if (pushLocalPawchiveArtists) {
        final remoteKeys = remoteArtists.map((a) => a.key).toSet();
        for (final raw in currentFavorites) {
          try {
            final parsed = FavoriteArtistItem.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            );
            if (parsed.providerId == 'pawchive' &&
                !remoteKeys.contains(parsed.key)) {
              await toggleRemoteFavorite(
                account: account,
                service: parsed.service,
                artistId: parsed.id,
                isFavorite: true,
              );
            }
          } catch (_) {}
        }
      }

      // Update account sync stats in settings
      final updatedAccount = account.copyWith(
        lastSyncedAt: DateTime.now(),
        syncedArtistsCount: remoteArtists.length,
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
        totalSyncedCount: remoteArtists.length,
      );
    } catch (e) {
      return PawchiveSyncResult(
        updatedSettings: settings,
        newlyAddedToLocal: 0,
        totalSyncedCount: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Synchronizes ALL connected Pawchive accounts with local AppSettings.
  Future<PawchiveSyncResult> syncAllAccounts({
    required AppSettings settings,
  }) async {
    final accounts = settings.parsedPawchiveAccounts;
    if (accounts.isEmpty) {
      return PawchiveSyncResult(
        updatedSettings: settings,
        newlyAddedToLocal: 0,
        totalSyncedCount: 0,
        errorMessage: 'Нет добавленных аккаунтов Pawchive',
      );
    }

    var runningSettings = settings;
    var totalAdded = 0;
    var totalSynced = 0;
    String? firstError;

    for (final account in accounts) {
      final res = await syncAccountFavorites(
        account: account,
        settings: runningSettings,
      );
      if (res.isSuccess) {
        runningSettings = res.updatedSettings;
        totalAdded += res.newlyAddedToLocal;
        totalSynced += res.totalSyncedCount;
      } else {
        firstError ??= res.errorMessage;
      }
    }

    return PawchiveSyncResult(
      updatedSettings: runningSettings,
      newlyAddedToLocal: totalAdded,
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

    final path = '$normalizedBase/favorites/creator/$service/$artistId';
    final options = Options(
      headers: {
        'Cookie': 'session=$cleanCookie',
        'User-Agent': 'Lunaris/2.0.1 Flutter local booru browser',
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
