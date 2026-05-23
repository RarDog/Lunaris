import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';

final providersControllerProvider =
    AsyncNotifierProvider<ProvidersController, List<ContentProviderConfig>>(
  ProvidersController.new,
);

class ProvidersController extends AsyncNotifier<List<ContentProviderConfig>> {
  @override
  Future<List<ContentProviderConfig>> build() => _load();

  Future<void> toggle(String id, bool enabled) async {
    await ref.read(providerManagerProvider).enableProvider(id, enabled);
    state = AsyncData(await _load());
  }

  Future<void> save(ContentProviderConfig config) async {
    await ref.read(providerManagerProvider).addCustomProvider(config);
    state = AsyncData(await _load());
  }

  Future<void> delete(String id) async {
    await ref.read(providerManagerProvider).deleteProvider(id);
    state = AsyncData(await _load());
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
