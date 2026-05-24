import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/post_masonry_grid.dart';
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
    final viewedKeys = ref.watch(viewedKeysProvider).value ?? <String>{};
    return AdaptiveScaffold(
      title: 'Viewed',
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
        data: (posts) => posts.isEmpty
            ? const EmptyView(title: 'No viewed posts yet')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(viewedControllerProvider.notifier).refresh(),
                child: PostMasonryGrid(
                  posts: posts,
                  columns: Responsive.columnsFor(
                    context,
                    mobileColumns: settings.mobileColumns,
                    desktopColumns: settings.desktopColumns,
                  ),
                  blurExplicit: settings.blurExplicitContent,
                  showBadges: settings.showPostBadges,
                  nsfwEnabled: settings.nsfwEnabled,
                  favoriteKeys: favoriteKeys,
                  viewedKeys: viewedKeys,
                  onOpen: (post) => context.push(
                    '/post/${post.providerId}/${post.id}',
                    extra: post,
                  ),
                  onFavorite: (post) async {
                    if (favoriteKeys.contains(post.cacheKey)) {
                      await ref
                          .read(favoriteServiceProvider)
                          .removeFavorite(post.id, post.providerId);
                    } else {
                      await ref.read(favoriteServiceProvider).addFavorite(post);
                    }
                    ref.invalidate(favoriteKeysProvider);
                  },
                ),
              ),
      ),
    );
  }
}
