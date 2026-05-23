import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_view.dart';
import 'providers_controller.dart';
import 'widgets/provider_card.dart';

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providersControllerProvider);
    return AdaptiveScaffold(
      title: 'Providers',
      actions: [
        IconButton(
          tooltip: 'Check providers',
          onPressed: () => context.go('/providers/check'),
          icon: const Icon(Icons.network_check_rounded),
        ),
        IconButton(
          tooltip: 'Add provider',
          onPressed: () => context.go('/providers/new'),
          icon: const Icon(Icons.add_rounded),
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
            return ProviderCard(
              config: item,
              onToggle: (enabled) => ref
                  .read(providersControllerProvider.notifier)
                  .toggle(item.id, enabled),
              onEdit: () => context.go('/providers/new', extra: item),
              onDelete: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: 'Delete provider',
                  message: 'Remove ${item.name}?',
                );
                if (ok) {
                  await ref
                      .read(providersControllerProvider.notifier)
                      .delete(item.id);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
