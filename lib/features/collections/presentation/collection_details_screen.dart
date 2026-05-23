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
import 'collections_controller.dart';

class CollectionDetailsScreen extends ConsumerWidget {
  const CollectionDetailsScreen({required this.collectionId, super.key});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(collectionPostsProvider(collectionId));
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    return AdaptiveScaffold(
      title: 'Collection',
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (items) => items.isEmpty
            ? const EmptyView(title: 'Collection is empty')
            : PostMasonryGrid(
                posts: items,
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
                    ref.read(favoriteServiceProvider).addFavorite(post),
              ),
      ),
    );
  }
}
