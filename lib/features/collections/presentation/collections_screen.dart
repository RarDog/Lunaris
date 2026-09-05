import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../backend/backend.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_view.dart';
import 'collection_form_dialog.dart';
import 'collections_controller.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final isRu = settings.languageCode == 'ru';

    return AdaptiveScaffold(
      title: isRu ? 'Коллекции' : 'Collections',
      actions: [
        IconButton(
          tooltip: isRu ? 'Новая коллекция' : 'New collection',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => showCollectionFormDialog(context, ref),
        ),
      ],
      body: collections.when(
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
                      isRu ? 'Нет коллекций' : 'No collections yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRu
                          ? 'Создавайте тематические коллекции и объединяйте в них понравившиеся работы'
                          : 'Create themed collections and organize your favorite posts',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => showCollectionFormDialog(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        isRu ? 'Создать коллекцию' : 'Create collection',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.88,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _CollectionCard(
                collection: item,
                isRu: isRu,
                onOpen: () => context.go('/collections/${item.id}'),
                onEdit: () => showCollectionFormDialog(
                  context,
                  ref,
                  collection: item,
                ),
                onDelete: () async {
                  final ok = await showConfirmDialog(
                    context,
                    title: isRu ? 'Удалить коллекцию' : 'Delete collection',
                    message: isRu
                        ? 'Удалить подборку "${item.name}"?'
                        : 'Remove "${item.name}"?',
                  );
                  if (ok) {
                    await ref
                        .read(collectionsControllerProvider.notifier)
                        .delete(item.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CollectionCard extends ConsumerWidget {
  const _CollectionCard({
    required this.collection,
    required this.isRu,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Collection collection;
  final bool isRu;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final postsAsync = ref.watch(collectionPostsProvider(collection.id));
    final posts = postsAsync.value ?? const <Post>[];
    final previewUrls = posts
        .map((p) => MediaUrlSelector.preview(p).firstOrNull)
        .whereType<String>()
        .take(4)
        .toList();

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Collage (2x2 or Hero)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCoverMosaic(previewUrls, scheme),
                  // Glass count badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${posts.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (collection.description != null &&
                            collection.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            collection.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: isRu ? 'Действия' : 'Actions',
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.edit_rounded, size: 20),
                          title: Text(isRu ? 'Редактировать' : 'Edit'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.delete_rounded, size: 20),
                          title: Text(isRu ? 'Удалить' : 'Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverMosaic(List<String> urls, ColorScheme scheme) {
    if (urls.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.6),
              scheme.tertiaryContainer.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.collections_bookmark_rounded,
            size: 40,
            color: scheme.primary,
          ),
        ),
      );
    }

    if (urls.length == 1) {
      return CachedNetworkImage(
        imageUrl: urls[0],
        memCacheWidth: 260,
        memCacheHeight: 260,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: scheme.surfaceContainerHighest),
        errorWidget: (_, __, ___) => Container(
          color: scheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_rounded),
        ),
      );
    }

    // Mosaic grid (up to 4)
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i = 0; i < 4; i++)
          if (i < urls.length)
            CachedNetworkImage(
              imageUrl: urls[i],
              memCacheWidth: 200,
              memCacheHeight: 200,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: scheme.surfaceContainerHighest),
              errorWidget: (_, __, ___) => Container(
                color: scheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_rounded, size: 16),
              ),
            )
          else
            Container(color: scheme.surfaceContainerHighest),
      ],
    );
  }
}
