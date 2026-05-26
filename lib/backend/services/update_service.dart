import 'package:dio/dio.dart';
import 'dart:io';

import '../../app/app_version.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../models/app_update_info.dart';
import 'settings_service.dart';

class UpdateService {
  UpdateService(this._dio, this._settingsService);

  static const latestReleaseUrl =
      'https://gitea.rardogsynapse.online/api/v1/repos/RarDog/RuleGelApp/releases/latest';
  static const releasesUrl =
      'https://gitea.rardogsynapse.online/api/v1/repos/RarDog/RuleGelApp/releases';

  final Dio _dio;
  final SettingsService _settingsService;

  Future<Result<AppUpdateInfo?>> checkForUpdates({bool force = false}) async {
    final settingsResult = await _settingsService.getSettings();
    final settings = settingsResult is Success<AppSettings>
        ? settingsResult.data
        : AppSettings.defaults;

    try {
      final info = await _latestAllowedRelease(settings);
      final nextSettings = settings.copyWith(
        lastUpdateCheckAt: DateTime.now().toIso8601String(),
      );
      await _settingsService.updateSettings(nextSettings);

      final skipped = settings.skippedUpdateVersion == info.version ||
          settings.skippedUpdateVersion == info.tagName;
      if (!force && skipped) return const Success(null);
      if (!_isNewerVersion(info.version, appDisplayVersion)) {
        return const Success(null);
      }
      return Success(info);
    } catch (error) {
      return Error(
        Failure(
          code: 'update_check_failed',
          message: 'Could not check for updates',
          details: error,
        ),
      );
    }
  }

  Future<AppUpdateInfo> _latestAllowedRelease(AppSettings settings) async {
    final response = await _dio.get<dynamic>(
      releasesUrl,
      queryParameters: {'limit': 30},
    );
    final items = (response.data as List?) ?? const [];
    final releases = items
        .whereType<Map>()
        .where((item) => item['draft'] != true)
        .where((item) =>
            settings.allowExperimentalUpdates || item['prerelease'] != true)
        .map((item) => _releaseFromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    if (releases.isEmpty) {
      final latest = await _dio.get<dynamic>(latestReleaseUrl);
      return _releaseFromJson(Map<String, dynamic>.from(latest.data as Map));
    }
    releases.sort((a, b) {
      final versionCompare = _compareVersions(b.version, a.version);
      if (versionCompare != 0) return versionCompare;
      final left = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return left.compareTo(right);
    });
    return releases.first;
  }

  Future<Result<void>> remindLater() async {
    final result = await _settingsService.getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    return _settingsService.updateSettings(
      settings.copyWith(lastUpdateCheckAt: DateTime.now().toIso8601String()),
    );
  }

  Future<Result<void>> skipVersion(AppUpdateInfo info) async {
    final result = await _settingsService.getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    return _settingsService.updateSettings(
      settings.copyWith(skippedUpdateVersion: info.version),
    );
  }

  AppUpdateInfo _releaseFromJson(Map<String, dynamic> json) {
    final tag = (json['tag_name'] ?? '').toString();
    final assets = (json['assets'] as List?) ?? const [];
    String? apkUrl;
    String? installerUrl;
    String? portableUrl;
    for (final item in assets.whereType<Map>()) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final url = (item['browser_download_url'] ?? '').toString();
      if (url.isEmpty) continue;
      if (name.endsWith('.apk')) apkUrl = url;
      if (name.endsWith('.exe')) installerUrl = url;
      if (name.endsWith('.zip')) portableUrl = url;
    }
    return AppUpdateInfo(
      version: _versionFromTag(tag),
      tagName: tag,
      name: (json['name'] ?? tag).toString(),
      body: (json['body'] ?? '').toString(),
      htmlUrl: (json['html_url'] ?? '').toString(),
      publishedAt: DateTime.tryParse((json['published_at'] ?? '').toString()),
      apkUrl: apkUrl,
      windowsInstallerUrl: installerUrl,
      portableZipUrl: portableUrl,
    );
  }

  String? assetUrlForCurrentPlatform(AppUpdateInfo info) {
    if (Platform.isAndroid) {
      return info.apkUrl;
    }
    if (Platform.isWindows) {
      return info.windowsInstallerUrl ?? info.portableZipUrl;
    }
    return info.portableZipUrl;
  }

  String assetFileName(AppUpdateInfo info, String url) {
    final parsed = Uri.tryParse(url);
    final fromUrl =
        parsed?.pathSegments.isEmpty ?? true ? '' : parsed!.pathSegments.last;
    if (fromUrl.contains('.')) return fromUrl;
    if (Platform.isAndroid) return 'Lunaris-v${info.version}.apk';
    if (Platform.isWindows) return 'LunarisSetup-v${info.version}.exe';
    return 'LunarisPortable-v${info.version}.zip';
  }

  static String _versionFromTag(String tag) {
    final match = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(tag);
    return match?.group(1) ?? tag.replaceFirst(RegExp(r'^v'), '');
  }

  static bool _isNewerVersion(String latest, String current) {
    return _compareVersions(latest, current) > 0;
  }

  static int _compareVersions(String latest, String current) {
    final left = _parts(latest);
    final right = _parts(current);
    for (var i = 0; i < 3; i++) {
      if (left[i] > right[i]) return 1;
      if (left[i] < right[i]) return -1;
    }
    return 0;
  }

  static List<int> _parts(String value) {
    final match = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(value);
    if (match == null) return const [0, 0, 0];
    return [
      int.tryParse(match.group(1) ?? '') ?? 0,
      int.tryParse(match.group(2) ?? '') ?? 0,
      int.tryParse(match.group(3) ?? '') ?? 0,
    ];
  }
}
