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
            SwitchListTile(
              value: settings.hideViewedPosts,
              title: const Text('Hide viewed posts'),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(hideViewedPosts: value)),
            ),
            const SizedBox(height: 12),
            _TagListEditor(
              title: 'Smart blacklist',
              icon: Icons.visibility_off_rounded,
              tags: settings.smartBlacklistRules,
              helper:
                  'Examples: tag, tag_a tag_b, provider:e621, rating:explicit, type:video, score:<10, artist:name',
              onChanged: (tags) => _update(
                ref,
                settings.copyWith(smartBlacklistRules: tags),
              ),
            ),
            const SizedBox(height: 12),
            _TagListEditor(
              title: 'Whitelisted tags',
              icon: Icons.verified_rounded,
              tags: settings.whitelistedTags,
              onChanged: (tags) => _update(
                ref,
                settings.copyWith(whitelistedTags: tags),
              ),
            ),
            const SizedBox(height: 12),
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
              onPressed: () => ref
                  .read(settingsControllerProvider.notifier)
                  .clearViewedHistory(),
              icon: const Icon(Icons.history_toggle_off_rounded),
              label: const Text('Clear viewed history'),
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
              label: const Text('Export settings and providers JSON'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _importDialog(context, ref),
              icon: const Icon(Icons.download_for_offline_rounded),
              label: const Text('Import settings and providers JSON'),
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

class _TagListEditor extends StatefulWidget {
  const _TagListEditor({
    required this.title,
    required this.icon,
    required this.tags,
    required this.onChanged,
    this.helper,
  });

  final String title;
  final IconData icon;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String? helper;

  @override
  State<_TagListEditor> createState() => _TagListEditorState();
}

class _TagListEditorState extends State<_TagListEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (widget.helper != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.helper!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in widget.tags)
                  InputChip(
                    label: Text(tag),
                    onDeleted: () => widget.onChanged(
                      widget.tags.where((item) => item != tag).toList(),
                    ),
                  ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Add tags',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Add tags',
                  onPressed: _submit,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final incoming = _controller.text
        .split(RegExp(r'\s+'))
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty);
    final merged = <String>{...widget.tags, ...incoming}.toList()..sort();
    _controller.clear();
    widget.onChanged(merged);
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
