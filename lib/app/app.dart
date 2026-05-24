import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../backend/backend.dart';
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
      data: (_) => MaterialApp.router(
        title: 'RuleGel',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: settings.maybeWhen(
          data: (value) => parseThemeMode(value.themeMode),
          orElse: () => ThemeMode.dark,
        ),
        routerConfig: router,
        builder: (context, child) => _DownloadOverlay(child: child),
      ),
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
                        tooltip: 'Retry',
                        onPressed: () => ref
                            .read(downloadManagerServiceProvider)
                            .retry(task.id),
                        icon: const Icon(Icons.refresh_rounded),
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
                  'Could not start local database',
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
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
