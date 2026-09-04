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
import 'collection_form_dialog.dart';
import 'collections_controller.dart';

class CollectionDetailsScreen extends ConsumerWidget {
  const CollectionDetailsScreen({required this.collectionId, super.key});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(collectionPostsProvider(collectionId));
    final collections = ref.watch(collectionsControllerProvider).valueOrNull;
    final collection = collections
        ?.where((c) => c.id == collectionId)
        .firstOrNull;
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final isRu = settings.languageCode == 'ru';
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};

    return AdaptiveScaffold(
      title: collection?.name ?? (isRu ? 'Коллекция' : 'Collection'),
      actions: [
        if (collection != null) ...[
          IconButton(
            tooltip: isRu ? 'Редактировать' : 'Edit',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => showCollectionFormDialog(
              context,
              ref,
              collection: collection,
            ),
          ),
          IconButton(
            tooltip: isRu ? 'Удалить' : 'Delete',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: isRu ? 'Удалить коллекцию' : 'Delete collection',
                message: isRu
                    ? 'Удалить подборку "${collection.name}"?'
                    : 'Remove "${collection.name}"?',
              );
              if (ok) {
                await ref
                    .read(collectionsControllerProvider.notifier)
                    .delete(collection.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ],
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (items) {
          if (items.isEmpty) {
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
                        Icons.collections_bookmark_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRu ? 'В коллекции пока нет постов' : 'Collection is empty',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRu
                          ? 'Добавляйте посты из ленты через меню «Добавить в коллекцию» на карточке поста'
                          : 'Add posts to this collection using "Add to collection" from post cards in the feed',
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

          return Column(
            children: [
              if (collection?.description != null &&
                  collection!.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      collection.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              Expanded(
                child: PostMasonryGrid(
                  posts: items,
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
                      posts: items,
                    ),
                  ),
                  onFavorite: (post) async {
                    if (favoriteKeys.contains(post.cacheKey)) {
                      await ref
                          .read(favoriteServiceProvider)
                          .removeFavorite(post.id, post.providerId);
                    } else {
                      await ref.read(favoriteServiceProvider).addFavorite(
                            post,
                            settings: settings,
                            downloadManager:
                                ref.read(downloadManagerServiceProvider),
                          );
                    }
                    ref.invalidate(favoriteKeysProvider);
                    ref.invalidate(favoritesControllerProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
