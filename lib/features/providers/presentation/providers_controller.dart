import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../feed/presentation/feed_controller.dart';

final providersControllerProvider =
    AsyncNotifierProvider<ProvidersController, List<ContentProviderConfig>>(
  ProvidersController.new,
);

class ProvidersController extends AsyncNotifier<List<ContentProviderConfig>> {
  @override
  Future<List<ContentProviderConfig>> build() => _load();

  Future<void> toggle(String id, bool enabled) async {
    await ref.read(providerManagerProvider).enableProvider(id, enabled);
    if (!enabled) {
      final settingsResult =
          await ref.read(settingsServiceProvider).getSettings();
      if (settingsResult is Success<AppSettings>) {
        final settings = settingsResult.data;
        await ref.read(settingsServiceProvider).updateSettings(
              settings.copyWith(
                selectedFeedProviderIds: settings.selectedFeedProviderIds
                    .where((providerId) => providerId != id)
                    .toList(growable: false),
                lastFeedProviderIds: settings.lastFeedProviderIds
                    .where((providerId) => providerId != id)
                    .toList(growable: false),
                enabledProviderIds: settings.enabledProviderIds
                    .where((providerId) => providerId != id)
                    .toList(growable: false),
              ),
            );
      }
    }
    state = AsyncData(await _load());
    ref.invalidate(feedControllerProvider);
    ref.invalidate(appSettingsProvider);
    ref.invalidate(providerDiagnosticsProvider);
  }

  Future<void> save(ContentProviderConfig config) async {
    await ref.read(providerManagerProvider).addCustomProvider(config);
    state = AsyncData(await _load());
    ref.invalidate(feedControllerProvider);
    ref.invalidate(appSettingsProvider);
  }

  Future<void> delete(String id) async {
    await ref.read(providerManagerProvider).deleteProvider(id);
    state = AsyncData(await _load());
    ref.invalidate(feedControllerProvider);
    ref.invalidate(appSettingsProvider);
  }

  Future<List<ContentProviderConfig>> _load() async {
    final result =
        await ref.read(providerManagerProvider).loadConfigs(enabledOnly: false);
    return result is Success<List<ContentProviderConfig>>
        ? result.data
        : const [];
  }
}

final providerHealthProvider =
    StateProvider<Map<String, ProviderHealth>>((ref) => {});

final providerDiagnosticsProvider =
    FutureProvider<Map<String, ProviderDiagnostics>>((ref) async {
  final result = await ref.watch(providerRepositoryProvider).getDiagnostics();
  if (result is Success<List<ProviderDiagnostics>>) {
    return {
      for (final item in result.data) item.providerId: item,
    };
  }
  return {};
});
