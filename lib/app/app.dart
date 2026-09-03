import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../backend/backend.dart';
import '../core/utils/result.dart';
import 'app_strings.dart';
import 'motion.dart';
import 'router.dart';
import 'theme.dart';

class GelRuleApp extends ConsumerWidget {
  const GelRuleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);
    final settings = ref.watch(appSettingsProvider);
    final router = ref.watch(appRouterProvider);

    return database.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _StartupLoadingScreen(),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: ThemeMode.dark,
        home: _StartupErrorScreen(error: error),
      ),
      data: (_) {
        final appSettings = settings.value ?? AppSettings.defaults;
        return MaterialApp.router(
          title: 'Lunaris',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(
            Brightness.light,
            seedColor: appSettings.appSeedColor,
          ),
          darkTheme: buildTheme(
            Brightness.dark,
            seedColor: appSettings.appSeedColor,
          ),
          themeMode: parseThemeMode(appSettings.themeMode),
          routerConfig: router,
          builder: (context, child) => _AppOverlay(child: child),
        );
      },
    );
  }
}

class _AppOverlay extends ConsumerStatefulWidget {
  const _AppOverlay({required this.child});

  final Widget? child;

  @override
  ConsumerState<_AppOverlay> createState() => _AppOverlayState();
}

class _AppOverlayState extends ConsumerState<_AppOverlay> {
  bool _checkedUpdates = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedUpdates) return;
    _checkedUpdates = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdates());
  }

  Future<void> _checkUpdates() async {
    final result = await ref.read(updateServiceProvider).checkForUpdates();
    if (!mounted || result is! Success<AppUpdateInfo?> || result.data == null) {
      return;
    }
    await _showUpdateDialog(result.data!);
  }

  Future<void> _showUpdateDialog(AppUpdateInfo info) async {
    final strings = ref.read(appStringsProvider);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${strings.appUpdateAvailable}: Lunaris ${info.version}'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.name),
                if (info.body.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    info.body.trim(),
                    maxLines: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(updateServiceProvider).skipVersion(info);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(strings.skipThisVersion),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(updateServiceProvider).remindLater();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(strings.later),
          ),
          FilledButton.icon(
            onPressed: () async {
              await _downloadUpdate(info);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.download_rounded),
            label: Text(strings.downloadAndOpen),
          ),
        ],
      ),
    );
    ref.invalidate(appSettingsProvider);
  }

  Future<void> _downloadUpdate(AppUpdateInfo info) async {
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

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingsProvider).value;
    final isAndroid = Platform.isAndroid;
    final deviceInfo =
        isAndroid ? ref.watch(motionDeviceInfoProvider).value : null;
    final view = isAndroid ? View.maybeOf(context) : null;
    final detectedHz = isAndroid ? view?.display.refreshRate ?? 60.0 : 60.0;
    final motion = resolveMotionSettings(
      settings: appSettings ?? AppSettings.defaults,
      detectedHz: detectedHz,
      device: deviceInfo,
    );
    if (isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(deviceMotionServiceProvider)
            .setPreferredRefreshRate(motion.effectiveHz);
      });
    }
    return AppMotionScope(
      settings: motion,
      child: _DownloadOverlay(child: widget.child),
    );
  }
}

class _DownloadOverlay extends ConsumerWidget {
  const _DownloadOverlay({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(downloadTasksProvider).value ?? const [];
    final visible = tasks
        .where((task) =>
            task.status == DownloadTaskStatus.running ||
            task.status == DownloadTaskStatus.queued ||
            task.status == DownloadTaskStatus.failed ||
            task.status == DownloadTaskStatus.completed)
        .toList();
    return Stack(
      children: [
        if (child != null) child!,
        if (visible.isNotEmpty)
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: _DownloadPanel(tasks: visible.take(3).toList()),
            ),
          ),
      ],
    );
  }
}

class _DownloadPanel extends ConsumerWidget {
  const _DownloadPanel({required this.tasks});

  final List<DownloadTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final strings = ref.watch(appStringsProvider);
    final manager = ref.read(downloadManagerServiceProvider);
    final paused = manager.queuePaused;
    final activeTasks = tasks
        .where((task) =>
            task.status == DownloadTaskStatus.queued ||
            task.status == DownloadTaskStatus.running)
        .toList();
    final finishedTasks = tasks
        .where((task) =>
            task.status == DownloadTaskStatus.completed ||
            task.status == DownloadTaskStatus.failed ||
            task.status == DownloadTaskStatus.canceled)
        .toList();
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(16),
      color: scheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    strings.download,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: paused ? 'Resume queue' : 'Pause queue',
                    onPressed:
                        paused ? manager.resumeQueue : manager.pauseQueue,
                    icon: Icon(paused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded),
                  ),
                  if (activeTasks.isNotEmpty)
                    IconButton(
                      tooltip: 'Cancel active',
                      onPressed: () {
                        for (final task in activeTasks) {
                          manager.cancel(task.id);
                        }
                      },
                      icon: const Icon(Icons.cancel_rounded),
                    ),
                  if (finishedTasks.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear finished',
                      onPressed: manager.clearFinished,
                      icon: const Icon(Icons.clear_all_rounded),
                    ),
                ],
              ),
              for (final task in tasks) ...[
                Row(
                  children: [
                    Icon(_icon(task.status), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (task.status == DownloadTaskStatus.failed)
                      IconButton(
                        tooltip: strings.retry,
                        onPressed: () => ref
                            .read(downloadManagerServiceProvider)
                            .retry(task.id),
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    if (task.status == DownloadTaskStatus.queued ||
                        task.status == DownloadTaskStatus.running)
                      IconButton(
                        tooltip: 'Cancel',
                        onPressed: () => ref
                            .read(downloadManagerServiceProvider)
                            .cancel(task.id),
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: task.status == DownloadTaskStatus.running
                      ? task.progress.clamp(0, 1)
                      : task.status == DownloadTaskStatus.completed
                          ? 1
                          : null,
                ),
                if (task.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      task.error!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                if (task != tasks.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(DownloadTaskStatus status) {
    return switch (status) {
      DownloadTaskStatus.completed => Icons.download_done_rounded,
      DownloadTaskStatus.failed => Icons.error_outline_rounded,
      DownloadTaskStatus.canceled => Icons.cancel_rounded,
      _ => Icons.download_rounded,
    };
  }
}

final appSettingsProvider = FutureProvider<AppSettings>((ref) {
  return ref.watch(settingsServiceProvider).getSettings().then(
        (result) => result.fold(
          onSuccess: (settings) => settings,
          onError: (_) => AppSettings.defaults,
        ),
      );
});

final appStringsProvider = Provider<AppStrings>((ref) {
  final settings = ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
  return AppStrings(settings.languageCode);
});

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: Center(
        child: CircularProgressIndicator(
          color: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE84D8A),
            brightness: Brightness.dark,
          ).primary,
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends ConsumerWidget {
  const _StartupErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  strings.ru
                      ? '\u041d\u0435 \u0443\u0434\u0430\u043b\u043e\u0441\u044c \u043e\u0442\u043a\u0440\u044b\u0442\u044c \u043b\u043e\u043a\u0430\u043b\u044c\u043d\u0443\u044e \u0431\u0430\u0437\u0443'
                      : 'Could not start local database',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(appDatabaseProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(strings.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
