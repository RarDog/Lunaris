import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/error_view.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return AdaptiveScaffold(
      title: 'Settings',
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: settings.themeMode,
              decoration: const InputDecoration(labelText: 'Theme'),
              items: const [
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (value) =>
                  _update(ref, settings.copyWith(themeMode: value ?? 'dark')),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: settings.blurExplicitContent,
              title: const Text('Blur sensitive previews'),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(blurExplicitContent: value)),
            ),
            SwitchListTile(
              value: settings.nsfwEnabled,
              title: const Text('Allow NSFW content'),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(nsfwEnabled: value)),
            ),
            SwitchListTile(
              value: settings.showPostBadges,
              title: const Text('Show post badges'),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(showPostBadges: value)),
            ),
            SwitchListTile(
              value: settings.allowDownloads,
              title: const Text('Allow manual downloads'),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(allowDownloads: value)),
            ),
            _StepperTile(
              title: 'Desktop columns',
              value: settings.desktopColumns,
              min: 3,
              max: 8,
              onChanged: (value) => _update(
                ref,
                settings.copyWith(desktopColumns: value),
              ),
            ),
            _StepperTile(
              title: 'Mobile columns',
              value: settings.mobileColumns,
              min: 1,
              max: 3,
              onChanged: (value) => _update(
                ref,
                settings.copyWith(mobileColumns: value),
              ),
            ),
            _StepperTile(
              title: 'Cache max items',
              value: settings.cacheMaxItems,
              min: 100,
              max: 10000,
              step: 100,
              onChanged: (value) =>
                  _update(ref, settings.copyWith(cacheMaxItems: value)),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () =>
                  ref.read(settingsControllerProvider.notifier).clearCache(),
              icon: const Icon(Icons.cleaning_services_rounded),
              label: const Text('Clear cache'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () async {
                final json = await ref
                    .read(settingsControllerProvider.notifier)
                    .exportJson();
                await Clipboard.setData(ClipboardData(text: json));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings JSON copied')),
                  );
                }
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Export settings JSON'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _importDialog(context, ref),
              icon: const Icon(Icons.download_for_offline_rounded),
              label: const Text('Import settings JSON'),
            ),
            const SizedBox(height: 24),
            const Text('Version 0.1.0'),
          ],
        ),
      ),
    );
  }

  Future<void> _update(WidgetRef ref, AppSettings settings) {
    return ref.read(settingsControllerProvider.notifier).saveSettings(settings);
  }

  Future<void> _importDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import settings'),
        content: TextField(
          controller: controller,
          minLines: 6,
          maxLines: 12,
          decoration: const InputDecoration(labelText: 'JSON'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(settingsControllerProvider.notifier)
                  .importJson(controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  final String title;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value <= min ? null : () => onChanged(value - step),
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(width: 52, child: Center(child: Text('$value'))),
          IconButton(
            onPressed: value >= max ? null : () => onChanged(value + step),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
