import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/error_view.dart';
import 'providers_controller.dart';
import 'widgets/provider_health_tile.dart';

class ProviderCheckScreen extends ConsumerWidget {
  const ProviderCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providersControllerProvider);
    final health = ref.watch(providerHealthProvider);
    final diagnostics = ref.watch(providerDiagnosticsProvider).value ?? {};
    return AdaptiveScaffold(
      title: 'Provider Check',
      actions: [
        IconButton(
          tooltip: 'Check all',
          onPressed: () => _checkAll(ref),
          icon: const Icon(Icons.playlist_add_check_rounded),
        ),
      ],
      body: providers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (items) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ProviderHealthTile(
              config: item,
              health: health[item.id],
              diagnostics: diagnostics[item.id],
              onCheck: () => _checkOne(ref, item.id),
            );
          },
        ),
      ),
    );
  }

  Future<void> _checkAll(WidgetRef ref) async {
    final result = await ref.read(providerCheckServiceProvider).checkAll();
    if (result is Success<List<ProviderHealth>>) {
      ref.read(providerHealthProvider.notifier).state = {
        for (final item in result.data) item.providerId: item,
      };
    }
  }

  Future<void> _checkOne(WidgetRef ref, String providerId) async {
    final result =
        await ref.read(providerCheckServiceProvider).checkOne(providerId);
    if (result is Success<ProviderHealth>) {
      ref.read(providerHealthProvider.notifier).state = {
        ...ref.read(providerHealthProvider),
        providerId: result.data,
      };
    }
  }
}
