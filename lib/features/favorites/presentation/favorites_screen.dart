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
import 'favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    return AdaptiveScaffold(
      title: 'Favorites',
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (data) => data.posts.isEmpty
            ? const EmptyView(title: 'No favorites yet')
            : PostMasonryGrid(
                posts: data.posts,
                columns: Responsive.columnsFor(
                  context,
                  mobileColumns: settings.mobileColumns,
                  desktopColumns: settings.desktopColumns,
                ),
                blurExplicit: settings.blurExplicitContent,
                showBadges: settings.showPostBadges,
                nsfwEnabled: settings.nsfwEnabled,
                onOpen: (post) => context.push(
                  '/post/${post.providerId}/${post.id}',
                  extra: post,
                ),
                onFavorite: (post) =>
                    ref.read(favoritesControllerProvider.notifier).remove(post),
              ),
      ),
    );
  }
}
