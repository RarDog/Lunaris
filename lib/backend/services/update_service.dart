import 'package:dio/dio.dart';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../app/app_version.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../models/app_update_info.dart';
import 'settings_service.dart';

enum UpdateSource {
  gitea,
  github,
}

class UpdateService {
  UpdateService(this._dio, this._settingsService);

  static const giteaLatestReleaseUrl =
      'https://gitea.rardogsynapse.online/api/v1/repos/RarDog/Lunaris/releases/latest';
  static const giteaReleasesUrl =
      'https://gitea.rardogsynapse.online/api/v1/repos/RarDog/Lunaris/releases';

  static const githubLatestReleaseUrl =
      'https://api.github.com/repos/RarDog/Lunaris/releases/latest';
  static const githubReleasesUrl =
      'https://api.github.com/repos/RarDog/Lunaris/releases';

  static const latestReleaseUrl = githubLatestReleaseUrl;
  static const releasesUrl = githubReleasesUrl;

  static const _deviceChannel = MethodChannel('rulegel/device');

  final Dio _dio;
  final SettingsService _settingsService;

  // Cached primary ABI (e.g. "arm64-v8a").
  String? _cachedPrimaryAbi;

  /// Returns the primary ABI of the running device.
  /// On non-Android platforms returns an empty string.
  Future<String> getPrimaryAbi() async {
    if (_cachedPrimaryAbi != null) return _cachedPrimaryAbi!;
    if (!Platform.isAndroid) return '';
    try {
      final abi = await _deviceChannel.invokeMethod<String>('getPrimaryAbi');
      _cachedPrimaryAbi = abi ?? 'armeabi-v7a';
    } catch (_) {
      _cachedPrimaryAbi = 'armeabi-v7a';
    }
    return _cachedPrimaryAbi!;
  }

  /// Returns all supported ABIs of the running device.
  Future<List<String>> getSupportedAbis() async {
    if (!Platform.isAndroid) return const [];
    try {
      final abis = await _deviceChannel.invokeMethod<List<Object?>>('getSupportedAbis');
      return abis?.whereType<String>().toList() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  Future<Result<AppUpdateInfo?>> checkForUpdates({
    bool force = false,
    UpdateSource source = UpdateSource.gitea,
  }) async {
    final settingsResult = await _settingsService.getSettings();
    final settings = settingsResult is Success<AppSettings>
        ? settingsResult.data
        : AppSettings.defaults;

    try {
      final info = await _latestAllowedRelease(settings, source: source);
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

  Future<AppUpdateInfo> _latestAllowedRelease(
    AppSettings settings, {
    UpdateSource source = UpdateSource.gitea,
  }) async {
    final isGitea = source == UpdateSource.gitea;
    final rUrl = isGitea ? giteaReleasesUrl : githubReleasesUrl;
    final latestUrl = isGitea ? giteaLatestReleaseUrl : githubLatestReleaseUrl;

    final options = Options(
      headers: isGitea
          ? {
              'Authorization': 'token 1c744d6044d756759d7b1f693c94c80cf70d75fa',
            }
          : {
              'User-Agent': 'Lunaris-App',
              'Accept': 'application/vnd.github+json',
            },
    );

    final response = await _dio.get<dynamic>(
      rUrl,
      queryParameters: isGitea ? {'limit': 30} : {'per_page': 30},
      options: options,
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
      final latest = await _dio.get<dynamic>(
        latestUrl,
        options: options,
      );
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
    String? apkArm64Url;
    String? apkArmv7Url;
    String? apkX86_64Url;
    String? installerUrl;
    String? portableUrl;
    String? linuxTarGzUrl;

    for (final item in assets.whereType<Map>()) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final url = (item['browser_download_url'] ?? '').toString();
      if (url.isEmpty) continue;

      if (name.endsWith('.apk')) {
        // Detect per-ABI APKs by name pattern produced by --split-per-abi.
        if (name.contains('arm64-v8a') || name.contains('arm64_v8a')) {
          apkArm64Url = url;
        } else if (name.contains('armeabi-v7a') || name.contains('armeabi_v7a')) {
          apkArmv7Url = url;
        } else if (name.contains('x86_64')) {
          apkX86_64Url = url;
        } else {
          // Universal / fat APK
          apkUrl = url;
        }
      }
      if (name.endsWith('.exe')) installerUrl = url;
      if (name.endsWith('.zip')) portableUrl = url;
      if (name.endsWith('.tar.gz') || name.endsWith('.tgz')) {
        linuxTarGzUrl = url;
      }
    }

    return AppUpdateInfo(
      version: _versionFromTag(tag),
      tagName: tag,
      name: (json['name'] ?? tag).toString(),
      body: (json['body'] ?? '').toString(),
      htmlUrl: (json['html_url'] ?? '').toString(),
      publishedAt: DateTime.tryParse((json['published_at'] ?? '').toString()),
      apkUrl: apkUrl,
      apkArm64Url: apkArm64Url,
      apkArmv7Url: apkArmv7Url,
      apkX86_64Url: apkX86_64Url,
      windowsInstallerUrl: installerUrl,
      portableZipUrl: portableUrl,
      linuxTarGzUrl: linuxTarGzUrl,
    );
  }

  /// Returns the download URL for the current platform/ABI.
  /// Pass [abi] (e.g. from [getPrimaryAbi]) on Android for per-ABI selection.
  Future<String?> assetUrlForCurrentPlatform(AppUpdateInfo info) async {
    if (Platform.isAndroid) {
      final abi = await getPrimaryAbi();
      return info.apkUrlForAbi(abi);
    }
    if (Platform.isLinux) {
      return info.linuxTarGzUrl ?? info.portableZipUrl;
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
    if (Platform.isLinux) return 'Lunaris-v${info.version}-linux-x64.tar.gz';
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
