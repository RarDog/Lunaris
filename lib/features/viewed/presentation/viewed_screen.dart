import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../backend/backend.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../favorites/presentation/favorites_controller.dart';
import 'viewed_controller.dart';

class ViewedScreen extends ConsumerWidget {
  const ViewedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(viewedControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};
    return AdaptiveScaffold(
      title: settings.languageCode == 'ru' ? 'История' : 'Viewed',
      actions: [
        IconButton(
          tooltip: 'Clear viewed history',
          onPressed: () => ref.read(viewedControllerProvider.notifier).clear(),
          icon: const Icon(Icons.history_toggle_off_rounded),
        ),
      ],
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (groups) => groups.isEmpty
            ? const EmptyView(title: 'No viewed posts yet')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(viewedControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  children: [
                    for (final group in groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        child: Text(
                          group.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      for (final item in group.items)
                        _ViewedPostTile(
                          post: item.post,
                          viewedAt: item.viewedAt,
                          isFavorite: favoriteKeys.contains(item.post.cacheKey),
                          onOpen: () {
                            final allPosts = [
                              for (final g in groups)
                                for (final i in g.items) i.post
                            ];
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
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
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
  }
}

class _ViewedPostTile extends StatelessWidget {
  const _ViewedPostTile({
    required this.post,
    required this.viewedAt,
    required this.isFavorite,
    required this.onOpen,
    required this.onFavorite,
  });

  final Post post;
  final DateTime viewedAt;
  final bool isFavorite;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final image = MediaUrlSelector.preview(post).firstOrNull;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onOpen,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 56,
            height: 56,
            child: image == null
                ? const Icon(Icons.image_not_supported_rounded)
                : Image.network(image, fit: BoxFit.cover),
          ),
        ),
        title: Text(post.tags.take(4).join(' '), maxLines: 1),
        subtitle: Text(
          '${post.providerName} • ${viewedAt.hour.toString().padLeft(2, '0')}:${viewedAt.minute.toString().padLeft(2, '0')}',
        ),
        trailing: IconButton(
          tooltip: isFavorite ? 'Remove favorite' : 'Favorite',
          onPressed: onFavorite,
          icon: Icon(isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded),
        ),
      ),
    );
  }
}
