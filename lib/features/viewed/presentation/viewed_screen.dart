import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(viewedControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final group in groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _localizedGroupLabel(group.label, isRu),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${group.items.length}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
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
    final image = MediaUrlSelector.preview(post).firstOrNull;
    final timeStr =
        '${viewedAt.hour.toString().padLeft(2, '0')}:${viewedAt.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Squircle Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      image == null
                          ? Container(
                              color: scheme.surfaceContainerHighest,
                              child: const Icon(Icons.image_not_supported_rounded),
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
                              borderRadius: BorderRadius.circular(4),
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
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  scheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              post.providerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onPrimaryContainer,
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
                            fontWeight: FontWeight.w500,
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
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: isFavorite
                    ? (isRu ? 'В избранном' : 'In favorites')
                    : (isRu ? 'В избранное' : 'Add to favorites'),
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.redAccent : scheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: isRu ? 'Удалить из истории' : 'Delete from history',
                onPressed: onDelete,
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
    );
  }
}
