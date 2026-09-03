import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/app.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';

class CacheStats {
  const CacheStats({
    required this.cachedPostsCount,
    required this.imageMemoryBytes,
    required this.imageMemoryCount,
    required this.tempDirectoryBytes,
    required this.downloadedCount,
  });

  final int cachedPostsCount;
  final int imageMemoryBytes;
  final int imageMemoryCount;
  final int tempDirectoryBytes;
  final int downloadedCount;

  int get totalEstimatedBytes =>
      imageMemoryBytes + tempDirectoryBytes + (cachedPostsCount * 2048);

  static const empty = CacheStats(
    cachedPostsCount: 0,
    imageMemoryBytes: 0,
    imageMemoryCount: 0,
    tempDirectoryBytes: 0,
    downloadedCount: 0,
  );
}

final cacheStatsProvider = FutureProvider.autoDispose<CacheStats>((ref) async {
  final cacheService = ref.watch(cacheServiceProvider);
  final downloadedService = ref.watch(downloadedMediaServiceProvider);

  final postsRes = await cacheService.getCachedPostsCount();
  final postsCount = postsRes is Success<int> ? postsRes.data : 0;

  final downloadedRes = await downloadedService.count();
  final downloadedCount =
      downloadedRes is Success<int> ? downloadedRes.data : 0;

  final imageCache = PaintingBinding.instance.imageCache;
  final memBytes = imageCache.currentSizeBytes;
  final memCount = imageCache.currentSize;

  var tempBytes = 0;
  try {
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      await for (final file
          in tempDir.list(recursive: true, followLinks: false)) {
        if (file is File) {
          tempBytes += await file.length();
        }
      }
    }
  } catch (_) {}

  return CacheStats(
    cachedPostsCount: postsCount,
    imageMemoryBytes: memBytes,
    imageMemoryCount: memCount,
    tempDirectoryBytes: tempBytes,
    downloadedCount: downloadedCount,
  );
});

class CacheManagerScreen extends ConsumerStatefulWidget {
  const CacheManagerScreen({super.key});

  @override
  ConsumerState<CacheManagerScreen> createState() => _CacheManagerScreenState();
}

class _CacheManagerScreenState extends ConsumerState<CacheManagerScreen> {
  bool _isClearing = false;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> _clearPostsCache() async {
    setState(() => _isClearing = true);
    await ref.read(cacheServiceProvider).clear();
    ref.invalidate(cacheStatsProvider);
    if (mounted) setState(() => _isClearing = false);
  }

  Future<void> _clearImagesCache() async {
    setState(() => _isClearing = true);
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    ref.invalidate(cacheStatsProvider);
    if (mounted) setState(() => _isClearing = false);
  }

  Future<void> _clearTempFiles() async {
    setState(() => _isClearing = true);
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        final entities = tempDir.listSync(recursive: false);
        for (final entity in entities) {
          try {
            entity.deleteSync(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}
    ref.invalidate(cacheStatsProvider);
    if (mounted) setState(() => _isClearing = false);
  }

  Future<void> _clearAllCache() async {
    setState(() => _isClearing = true);
    await ref.read(cacheServiceProvider).clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        final entities = tempDir.listSync(recursive: false);
        for (final entity in entities) {
          try {
            entity.deleteSync(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}
    ref.invalidate(cacheStatsProvider);
    if (mounted) setState(() => _isClearing = false);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(cacheStatsProvider);
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return AdaptiveScaffold(
      title: strings.ru ? 'Менеджер кэша' : 'Cache Manager',
      actions: [
        IconButton(
          tooltip: strings.ru ? 'Обновить' : 'Refresh',
          onPressed: () => ref.invalidate(cacheStatsProvider),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (stats) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Card(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatBytes(stats.totalEstimatedBytes),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.ru
                            ? 'Общий предполагаемый объем кэша'
                            : 'Total estimated cache size',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detail cards
              _CacheCategoryTile(
                icon: Icons.article_rounded,
                title: strings.ru ? 'Кэш постов (база данных)' : 'Posts cache (DB)',
                subtitle: strings.ru
                    ? '${stats.cachedPostsCount} сохраненных постов'
                    : '${stats.cachedPostsCount} cached posts',
                sizeText: _formatBytes(stats.cachedPostsCount * 2048),
                onClear: _isClearing ? null : _clearPostsCache,
              ),
              const SizedBox(height: 8),

              _CacheCategoryTile(
                icon: Icons.image_rounded,
                title: strings.ru ? 'Кэш картинок в памяти' : 'Image memory cache',
                subtitle: strings.ru
                    ? '${stats.imageMemoryCount} картинок в ОЗУ'
                    : '${stats.imageMemoryCount} images in RAM',
                sizeText: _formatBytes(stats.imageMemoryBytes),
                onClear: _isClearing ? null : _clearImagesCache,
              ),
              const SizedBox(height: 8),

              _CacheCategoryTile(
                icon: Icons.folder_open_rounded,
                title: strings.ru ? 'Временные файлы и медиа' : 'Temp files & media',
                subtitle: strings.ru
                    ? 'Файлы для отправки и временные буферы'
                    : 'Share exports & temporary buffers',
                sizeText: _formatBytes(stats.tempDirectoryBytes),
                onClear: _isClearing ? null : _clearTempFiles,
              ),
              const SizedBox(height: 8),

              _CacheCategoryTile(
                icon: Icons.download_done_rounded,
                title: strings.ru ? 'Скачанные медиа' : 'Downloaded media',
                subtitle: strings.ru
                    ? '${stats.downloadedCount} файлов в истории скачиваний'
                    : '${stats.downloadedCount} files in download history',
                sizeText: '',
                showClear: false,
              ),
              const SizedBox(height: 24),

              // Global action button
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isClearing ? null : _clearAllCache,
                icon: _isClearing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_sweep_rounded),
                label: Text(
                  strings.ru ? 'Очистить весь кэш' : 'Clear all cache',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CacheCategoryTile extends StatelessWidget {
  const _CacheCategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.sizeText,
    this.onClear,
    this.showClear = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String sizeText;
  final VoidCallback? onClear;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Icon(icon, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (sizeText.isNotEmpty) ...[
              Text(
                sizeText,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (showClear && onClear != null)
              IconButton(
                tooltip: 'Очистить',
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
