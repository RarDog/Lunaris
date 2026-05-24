import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_version.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
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
            DropdownButtonFormField<String>(
              initialValue: settings.mediaQualityMode,
              decoration: const InputDecoration(labelText: 'Media quality'),
              items: [
                for (final mode in MediaQualityMode.values)
                  DropdownMenuItem(value: mode.name, child: Text(mode.label)),
              ],
              onChanged: (value) => _update(
                ref,
                settings.copyWith(mediaQualityMode: value ?? 'auto'),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () => context.go('/providers'),
              icon: const Icon(Icons.hub_rounded),
              label: const Text('Providers'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () => context.go('/providers/check'),
              icon: const Icon(Icons.network_check_rounded),
              label: const Text('Provider diagnostics'),
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
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _checkUpdates(context, ref),
              icon: const Icon(Icons.system_update_alt_rounded),
              label: const Text('Check for updates'),
            ),
            const SizedBox(height: 24),
            const Text('Version $appDisplayVersion'),
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

  Future<void> _checkUpdates(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Checking for updates...')),
    );
    final result =
        await ref.read(updateServiceProvider).checkForUpdates(force: true);
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    if (result is Error<AppUpdateInfo?>) {
      messenger.showSnackBar(
        SnackBar(content: Text(result.failure.message)),
      );
      return;
    }
    final update = (result as Success<AppUpdateInfo?>).data;
    if (update == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('RuleGel is up to date')),
      );
      return;
    }
    await _updateDialog(context, ref, update);
  }

  Future<void> _updateDialog(
    BuildContext context,
    WidgetRef ref,
    AppUpdateInfo info,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('RuleGel ${info.version} is available'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Text(
              info.body.trim().isEmpty ? info.name : info.body.trim(),
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(updateServiceProvider).skipVersion(info);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Skip this version'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(updateServiceProvider).remindLater();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Later'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final url = Uri.tryParse(info.htmlUrl);
              if (url != null) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Update'),
          ),
        ],
      ),
    );
    ref.invalidate(settingsControllerProvider);
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
