import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../backend/backend.dart';
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

  Future<void> clearCache() async {
    await ref.read(cacheServiceProvider).clear();
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
