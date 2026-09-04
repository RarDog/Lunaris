import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/post_masonry_grid.dart';
import '../../favorites/presentation/favorites_controller.dart';
import 'viewed_controller.dart';

class ViewedScreen extends ConsumerStatefulWidget {
  const ViewedScreen({super.key});

  @override
  ConsumerState<ViewedScreen> createState() => _ViewedScreenState();
}

class _ViewedScreenState extends ConsumerState<ViewedScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(viewedControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final isRu = settings.languageCode == 'ru';
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};

    return AdaptiveScaffold(
      title: isRu ? 'История' : 'History',
      actions: [
        IconButton(
          tooltip: _isGridView
              ? (isRu ? 'Список' : 'List view')
              : (isRu ? 'Сетка' : 'Grid view'),
          icon: Icon(_isGridView
              ? Icons.view_agenda_rounded
              : Icons.grid_view_rounded),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        IconButton(
          tooltip: isRu ? 'Очистить историю' : 'Clear history',
          onPressed: () async {
            final confirm = await showConfirmDialog(
              context,
              title: isRu ? 'Очистить историю' : 'Clear history',
              message: isRu
                  ? 'Вы действительно хотите очистить всю историю просмотров?'
                  : 'Are you sure you want to clear your entire viewing history?',
            );
            if (confirm) {
              await ref.read(viewedControllerProvider.notifier).clear();
            }
          },
          icon: const Icon(Icons.delete_sweep_rounded),
        ),
      ],
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRu ? 'История просмотров пуста' : 'No viewed posts yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRu
                          ? 'Посты, которые вы открываете в ленте, будут сохраняться здесь'
                          : 'Posts you open from the feed will appear here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go('/feed'),
                      icon: const Icon(Icons.explore_rounded),
                      label: Text(isRu ? 'Перейти в ленту' : 'Explore Feed'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allPosts = [
            for (final g in groups)
              for (final i in g.items) i.post
          ];

          if (_isGridView) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(viewedControllerProvider.notifier).refresh(),
              child: PostMasonryGrid(
                posts: allPosts,
                columns: Responsive.columnsFor(
                  context,
                  mobileColumns: settings.mobileColumns,
                  desktopColumns: settings.desktopColumns,
                ),
                blurExplicit: settings.blurExplicitContent,
                showBadges: settings.showPostBadges,
                nsfwEnabled: settings.nsfwEnabled,
                mediaQualityMode:
                    MediaQualityMode.fromName(settings.mediaQualityMode),
                favoriteKeys: favoriteKeys,
                onOpen: (post) => context.push(
                  '/post/${post.providerId}/${post.id}',
                  extra: PostNavigationContext(
                    currentPost: post,
                    posts: allPosts,
                  ),
                ),
                onFavorite: (post) => _toggleFavorite(
                  ref,
                  post,
                  settings,
                  favoriteKeys,
                ),
              ),
            );
          }

          final bottomInset = MediaQuery.paddingOf(context).bottom;

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(viewedControllerProvider.notifier).refresh(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 140 + bottomInset),
              children: [
                for (final group in groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 16, 2, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.82),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.32),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _localizedGroupLabel(group.label, isRu),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.2,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5)
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.20),
                            ),
                          ),
                          child: Text(
                            '${group.items.length}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Theme.of(context).colorScheme.onSurfaceVariant
                                      : Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final item in group.items)
                    _ViewedPostTile(
                      post: item.post,
                      viewedAt: item.viewedAt,
                      isFavorite: favoriteKeys.contains(item.post.cacheKey),
                      isRu: isRu,
                      onOpen: () {
                        context.push(
                          '/post/${item.post.providerId}/${item.post.id}',
                          extra: PostNavigationContext(
                            currentPost: item.post,
                            posts: allPosts,
                          ),
                        );
                      },
                      onFavorite: () => _toggleFavorite(
                        ref,
                        item.post,
                        settings,
                        favoriteKeys,
                      ),
                      onDelete: () => ref
                          .read(viewedControllerProvider.notifier)
                          .deleteItem(item.post.providerId, item.post.id),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _localizedGroupLabel(String label, bool isRu) {
    if (!isRu) return label;
    if (label == 'Today') return 'Сегодня';
    if (label == 'Yesterday') return 'Вчера';
    return label;
  }

  Future<void> _toggleFavorite(
    WidgetRef ref,
    Post post,
    AppSettings settings,
    Set<String> favoriteKeys,
  ) async {
    if (favoriteKeys.contains(post.cacheKey)) {
      await ref
          .read(favoriteServiceProvider)
          .removeFavorite(post.id, post.providerId);
    } else {
      await ref.read(favoriteServiceProvider).addFavorite(
            post,
            settings: settings,
            downloadManager: ref.read(downloadManagerServiceProvider),
          );
    }
    ref.invalidate(favoriteKeysProvider);
    ref.invalidate(favoritesControllerProvider);
  }
}

class _ViewedPostTile extends StatelessWidget {
  const _ViewedPostTile({
    required this.post,
    required this.viewedAt,
    required this.isFavorite,
    required this.isRu,
    required this.onOpen,
    required this.onFavorite,
    required this.onDelete,
  });

  final Post post;
  final DateTime viewedAt;
  final bool isFavorite;
  final bool isRu;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  bool get _isVideo {
    final type = post.fileType.toLowerCase();
    final url = post.fileUrl.toLowerCase();
    return type == 'mp4' ||
        type == 'webm' ||
        url.endsWith('.mp4') ||
        url.endsWith('.webm');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = MediaUrlSelector.preview(post).firstOrNull;
    final timeStr =
        '${viewedAt.hour.toString().padLeft(2, '0')}:${viewedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.selectionClick();
                onOpen();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            scheme.surfaceContainerHigh
                                .withValues(alpha: 0.58),
                            scheme.surfaceContainerLow
                                .withValues(alpha: 0.36),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.88),
                            Colors.white.withValues(alpha: 0.72),
                          ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.13)
                        : Colors.white.withValues(alpha: 0.85),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  children: [
                    // Squircle Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : scheme.outlineVariant.withValues(alpha: 0.30),
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            image == null
                                ? Container(
                                    color: scheme.surfaceContainerHighest,
                                    child: const Icon(
                                        Icons.image_not_supported_rounded),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: image,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: scheme.surfaceContainerHighest,
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: scheme.surfaceContainerHighest,
                                      child: const Icon(
                                        Icons.broken_image_rounded,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                            if (_isVideo)
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Post details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.primary
                                        .withValues(alpha: isDark ? 0.20 : 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: scheme.primary.withValues(
                                          alpha: isDark ? 0.30 : 0.20),
                                    ),
                                  ),
                                  child: Text(
                                    post.providerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: scheme.primary,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                timeStr,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post.tags.isEmpty ? '#${post.id}' : post.tags.take(4).join(' '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                ),
                          ),
                          if (post.score != 0) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.thumb_up_rounded,
                                  size: 12,
                                  color: scheme.outline,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.score}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: scheme.outline,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Action buttons
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: isFavorite
                          ? (isRu ? 'В избранном' : 'In favorites')
                          : (isRu ? 'В избранное' : 'Add to favorites'),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onFavorite();
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? Colors.redAccent
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip:
                          isRu ? 'Удалить из истории' : 'Delete from history',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onDelete();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
