import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide appBuildNumber;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_version.dart';
import '../../../app/changelog.dart';
import '../../../app/app_strings.dart';
import '../../../app/motion.dart';
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
    final strings = AppStrings(
        settings.value?.languageCode ?? AppSettings.defaults.languageCode);
    return AdaptiveScaffold(
      title: strings.settings,
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (settings) => _SettingsContent(settings: settings),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAndroid = Platform.isAndroid;
    final strings = AppStrings(settings.languageCode);
    final deviceInfo =
        isAndroid ? ref.watch(motionDeviceInfoProvider).value : null;
    final detectedHz =
        isAndroid ? View.maybeOf(context)?.display.refreshRate ?? 60.0 : 60.0;
    final motion = isAndroid
        ? resolveMotionSettings(
            settings: settings,
            detectedHz: detectedHz,
            device: deviceInfo,
          )
        : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsSection(
          title: strings.general,
          icon: Icons.tune_rounded,
          children: [
            DropdownButtonFormField<String>(
              initialValue: settings.themeMode,
              decoration: InputDecoration(
                labelText: strings.theme,
              ),
              items: const [
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (value) =>
                  _update(ref, settings.copyWith(themeMode: value ?? 'dark')),
            ),
            SwitchListTile(
              value: settings.nsfwEnabled,
              title: Text(strings.allowNsfw),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(nsfwEnabled: value)),
            ),
            SwitchListTile(
              value: settings.blurExplicitContent,
              title: Text(strings.blurSensitive),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(blurExplicitContent: value)),
            ),
            SwitchListTile(
              value: settings.showPostBadges,
              title: Text(strings.showPostBadges),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(showPostBadges: value)),
            ),
            SwitchListTile(
              value: settings.allowDownloads,
              title: Text(strings.allowDownloads),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(allowDownloads: value)),
            ),
            SwitchListTile(
              value: settings.autoDownloadFavorites,
              title: Text(settings.languageCode == 'ru'
                  ? 'Offline избранное'
                  : 'Offline favorites'),
              subtitle: Text(settings.languageCode == 'ru'
                  ? 'При добавлении фото или видео в избранное файл скачивается в фоне для просмотра офлайн.'
                  : 'When a photo or video is added to Favorites, Lunaris downloads it in the background for offline viewing.'),
              onChanged: (value) => _update(
                ref,
                settings.copyWith(autoDownloadFavorites: value),
              ),
            ),
          ],
        ),
        _SettingsSection(
          title: strings.appearance,
          icon: Icons.palette_rounded,
          children: [
            DropdownButtonFormField<String>(
              initialValue: settings.languageCode,
              decoration: InputDecoration(labelText: strings.language),
              items: const [
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) => _update(
                ref,
                settings.copyWith(languageCode: value ?? 'ru'),
              ),
            ),
            const SizedBox(height: 12),
            _ColorSwatches(
              selected: settings.appSeedColor,
              onChanged: (color) =>
                  _update(ref, settings.copyWith(appSeedColor: color)),
            ),
            const SizedBox(height: 12),
            _TabVisibilityEditor(
              hiddenTabs: settings.hiddenTabs,
              onChanged: (hiddenTabs) =>
                  _update(ref, settings.copyWith(hiddenTabs: hiddenTabs)),
            ),
            SwitchListTile(
              value: settings.allowExperimentalUpdates,
              title: Text(settings.languageCode == 'ru'
                  ? 'Получать beta / experimental обновления'
                  : 'Receive beta / experimental updates'),
              subtitle: Text(settings.languageCode == 'ru'
                  ? 'Обновлятор будет видеть prerelease-сборки Gitea.'
                  : 'When enabled, the updater also sees prerelease Gitea builds.'),
              onChanged: (value) => _update(
                ref,
                settings.copyWith(allowExperimentalUpdates: value),
              ),
            ),
          ],
        ),
        _SettingsSection(
          title: strings.feedLayout,
          icon: Icons.dashboard_customize_rounded,
          children: [
            DropdownButtonFormField<String>(
              initialValue: settings.mediaQualityMode,
              decoration: InputDecoration(labelText: strings.mediaQuality),
              items: [
                for (final mode in MediaQualityMode.values)
                  DropdownMenuItem(value: mode.name, child: Text(mode.label)),
              ],
              onChanged: (value) => _update(
                ref,
                settings.copyWith(mediaQualityMode: value ?? 'auto'),
              ),
            ),
            if (isAndroid) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: settings.motionRefreshMode,
                decoration: const InputDecoration(
                  labelText: 'Animation refresh profile',
                ),
                items: [
                  for (final mode in MotionRefreshMode.values)
                    DropdownMenuItem(value: mode.name, child: Text(mode.label)),
                ],
                onChanged: (value) => _update(
                  ref,
                  settings.copyWith(motionRefreshMode: value ?? 'auto'),
                ),
              ),
              SwitchListTile(
                value: settings.autoBatterySaver60Hz,
                title: const Text('Auto 60 Hz below 20% battery'),
                subtitle: Text(
                  'Detected ${motion!.detectedHz.toStringAsFixed(0)} Hz'
                  '${motion.batteryLevel == null ? '' : ', battery ${motion.batteryLevel}%'}'
                  '${motion.batterySaverActive ? ', saver active' : ''}',
                ),
                onChanged: (value) => _update(
                  ref,
                  settings.copyWith(autoBatterySaver60Hz: value),
                ),
              ),
            ],
            _StepperTile(
              title: strings.desktopColumns,
              value: settings.desktopColumns,
              min: 3,
              max: 8,
              onChanged: (value) => _update(
                ref,
                settings.copyWith(desktopColumns: value),
              ),
            ),
            _StepperTile(
              title: strings.mobileColumns,
              value: settings.mobileColumns,
              min: 1,
              max: 3,
              onChanged: (value) => _update(
                ref,
                settings.copyWith(mobileColumns: value),
              ),
            ),
          ],
        ),
        _SettingsSection(
          title: strings.filters,
          icon: Icons.filter_alt_rounded,
          children: [
            SwitchListTile(
              value: settings.hideViewedPosts,
              title: Text(strings.hideViewed),
              onChanged: (value) =>
                  _update(ref, settings.copyWith(hideViewedPosts: value)),
            ),
            _TagListEditor(
              title: strings.smartBlacklist,
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
              title: strings.whitelistedTags,
              icon: Icons.verified_rounded,
              tags: settings.whitelistedTags,
              onChanged: (tags) => _update(
                ref,
                settings.copyWith(whitelistedTags: tags),
              ),
            ),
          ],
        ),
        _SettingsSection(
          title: strings.storage,
          icon: Icons.storage_rounded,
          children: [
            _StepperTile(
              title: strings.cacheMaxItems,
              value: settings.cacheMaxItems,
              min: 100,
              max: 10000,
              step: 100,
              onChanged: (value) =>
                  _update(ref, settings.copyWith(cacheMaxItems: value)),
            ),
            _ActionGrid(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => ref
                      .read(settingsControllerProvider.notifier)
                      .clearCache(),
                  icon: const Icon(Icons.cleaning_services_rounded),
                  label: Text(strings.clearCache),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ref
                      .read(settingsControllerProvider.notifier)
                      .clearViewedHistory(),
                  icon: const Icon(Icons.history_toggle_off_rounded),
                  label: Text(strings.clearViewed),
                ),
                FilledButton.tonalIcon(
                  onPressed: settings.hiddenPostKeys.isEmpty
                      ? null
                      : () => context.go('/settings/hidden'),
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restore hidden'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ref
                      .read(settingsControllerProvider.notifier)
                      .clearHiddenPosts(),
                  icon: const Icon(Icons.visibility_off_rounded),
                  label:
                      Text('Clear hidden (${settings.hiddenPostKeys.length})'),
                ),
              ],
            ),
          ],
        ),
        _SettingsSection(
          title: 'Providers & Diagnostics',
          icon: Icons.hub_rounded,
          children: [
            _ActionGrid(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/providers'),
                  icon: const Icon(Icons.hub_rounded),
                  label: const Text('Providers'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/providers/check'),
                  icon: const Icon(Icons.network_check_rounded),
                  label: const Text('Diagnostics'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _copyDiagnostics(context, ref),
                  icon: const Icon(Icons.bug_report_rounded),
                  label: const Text('Copy report'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _copyLogs(context, ref),
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: const Text('Copy logs'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => ref
                      .read(settingsControllerProvider.notifier)
                      .clearDiagnosticLogs(),
                  icon: const Icon(Icons.delete_sweep_rounded),
                  label: const Text('Clear logs'),
                ),
              ],
            ),
          ],
        ),
        _SettingsSection(
          title: strings.about,
          icon: Icons.info_rounded,
          children: [
            _ActionGrid(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _checkUpdates(context, ref),
                  icon: const Icon(Icons.system_update_alt_rounded),
                  label: Text(strings.checkUpdates),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _showChangelog(context),
                  icon: const Icon(Icons.new_releases_rounded),
                  label: const Text('What changed'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _exportJson(context, ref),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(strings.exportJson),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _importDialog(context, ref),
                  icon: const Icon(Icons.download_for_offline_rounded),
                  label: Text(strings.importJson),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Version $appDisplayVersion ($appBuildNumber)'),
          ],
        ),
      ],
    );
  }

  Future<void> _update(WidgetRef ref, AppSettings settings) {
    return ref.read(settingsControllerProvider.notifier).saveSettings(settings);
  }

  Future<void> _copyDiagnostics(BuildContext context, WidgetRef ref) async {
    final report =
        await ref.read(settingsControllerProvider.notifier).diagnosticsReport();
    await Clipboard.setData(ClipboardData(text: report));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics copied')),
    );
  }

  Future<void> _copyLogs(BuildContext context, WidgetRef ref) async {
    final logs =
        await ref.read(settingsControllerProvider.notifier).diagnosticLogs();
    await Clipboard.setData(ClipboardData(text: logs));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostic logs copied')),
    );
  }

  Future<void> _exportJson(BuildContext context, WidgetRef ref) async {
    final json =
        await ref.read(settingsControllerProvider.notifier).exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings JSON copied')),
    );
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
      messenger.showSnackBar(SnackBar(content: Text(result.failure.message)));
      return;
    }
    final update = (result as Success<AppUpdateInfo?>).data;
    if (update == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Lunaris is up to date')),
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
        title: Text('Lunaris ${info.version} is available'),
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
              await _downloadUpdate(ref, info);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download & open'),
          ),
        ],
      ),
    );
    ref.invalidate(settingsControllerProvider);
  }

  Future<void> _downloadUpdate(WidgetRef ref, AppUpdateInfo info) async {
    final updateService = ref.read(updateServiceProvider);
    final assetUrl = updateService.assetUrlForCurrentPlatform(info);
    if (assetUrl == null) {
      final url = Uri.tryParse(info.htmlUrl);
      if (url != null) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return;
    }
    await ref.read(downloadManagerServiceProvider).startUrl(
          url: assetUrl,
          fileName: updateService.assetFileName(info, assetUrl),
          openAfterDownload: true,
        );
  }

  Future<void> _showChangelog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lunaris changelog'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final change in lunarisChangelog) ...[
                  Text(
                    '${change.version} - ${change.title}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  for (final bullet in change.bullets)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Text('- $bullet'),
                    ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final child in children)
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180),
            child: child,
          ),
      ],
    );
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

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  static const colors = <(int, String)>[
    (0xFFE84D8A, 'Lunaris pink'),
    (0xFF8B5CF6, 'Violet'),
    (0xFF3B82F6, 'Azure'),
    (0xFF0EA5E9, 'Sky'),
    (0xFF14B8A6, 'Teal'),
    (0xFF22C55E, 'Green'),
    (0xFFEAB308, 'Amber'),
    (0xFFF97316, 'Orange'),
    (0xFFEF4444, 'Red'),
    (0xFFEC4899, 'Hot pink'),
    (0xFF6366F1, 'Indigo'),
    (0xFF64748B, 'Slate'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accent color', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final entry in colors)
              Tooltip(
                message:
                    '${entry.$2} #${entry.$1.toRadixString(16).substring(2).toUpperCase()}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onChanged(entry.$1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(entry.$1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected == entry.$1
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: selected == entry.$1 ? 3 : 1,
                      ),
                    ),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: selected == entry.$1
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TabVisibilityEditor extends StatelessWidget {
  const _TabVisibilityEditor({
    required this.hiddenTabs,
    required this.onChanged,
  });

  final List<String> hiddenTabs;
  final ValueChanged<List<String>> onChanged;

  static const tabs = <String, String>{
    'feed': 'Feed',
    'search': 'Search',
    'favorites': 'Favorites',
    'viewed': 'Viewed',
    'collections': 'Collections',
    'artists': 'Artists',
  };

  @override
  Widget build(BuildContext context) {
    final hidden = hiddenTabs.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Visible tabs', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in tabs.entries)
              FilterChip(
                selected: !hidden.contains(entry.key),
                label: Text(entry.value),
                onSelected: (visible) {
                  final next = {...hidden};
                  if (visible) {
                    next.remove(entry.key);
                  } else if (entry.key != 'feed') {
                    next.add(entry.key);
                  }
                  onChanged(next.toList()..sort());
                },
              ),
          ],
        ),
      ],
    );
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
