import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../app/app_version.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/result.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
        SettingsController.new);

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final result = await ref.read(settingsServiceProvider).getSettings();
    return result is Success<AppSettings> ? result.data : AppSettings.defaults;
  }

  Future<void> saveSettings(AppSettings settings) async {
    await ref.read(settingsServiceProvider).updateSettings(settings);
    state = AsyncData(settings);
    ref.invalidate(appSettingsProvider);
  }

  Future<void> setVideoPlayerVolume(double volume) async {
    final current = state.value ?? AppSettings.defaults;
    final clamped = volume.clamp(0.0, 100.0);
    if ((current.videoPlayerVolume - clamped).abs() < 0.01) return;
    final updated = current.copyWith(videoPlayerVolume: clamped);
    state = AsyncData(updated);
    await ref.read(settingsServiceProvider).setVideoPlayerVolume(clamped);
    ref.invalidate(appSettingsProvider);
  }

  Future<void> clearCache() async {
    await ref.read(cacheServiceProvider).clear();
  }

  Future<void> clearViewedHistory() async {
    await ref.read(viewedHistoryServiceProvider).clearHistory();
    ref.invalidate(viewedKeysProvider);
  }

  Future<void> clearHiddenPosts() async {
    await ref.read(settingsServiceProvider).clearHiddenPosts();
    ref.invalidate(appSettingsProvider);
    ref.invalidateSelf();
  }

  Future<void> clearSearchHistory() async {
    await ref.read(searchServiceProvider).clearHistory();
  }

  Future<void> clearTagCache() async {
    await ref.read(searchServiceProvider).clearTagCache();
  }

  Future<String> diagnosticsReport() async {
    final result =
        await ref.read(settingsServiceProvider).buildDiagnosticsReport(
              appVersion: appDisplayVersion,
              buildNumber: appBuildNumber,
            );
    return result is Success<String> ? result.data : '{}';
  }

  Future<String> diagnosticLogs() async {
    final settings = state.value ?? AppSettings.defaults;
    final persistent = settings.diagnosticLogLines;
    final runtime = AppLogger.lines;
    return [...persistent, ...runtime].join('\n');
  }

  Future<void> clearDiagnosticLogs() async {
    AppLogger.clear();
    await ref.read(settingsServiceProvider).clearDiagnosticLogs();
    ref.invalidateSelf();
  }

  Future<String> exportJson() async {
    final result =
        await ref.read(settingsServiceProvider).exportSettingsToJson();
    return result is Success<String> ? result.data : '{}';
  }

  Future<void> importJson(String json) async {
    await ref.read(settingsServiceProvider).importSettingsFromJson(json);
    ref.invalidate(appSettingsProvider);
    ref.invalidateSelf();
  }
}
