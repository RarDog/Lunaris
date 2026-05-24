import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/post_masonry_grid.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../viewed/presentation/viewed_controller.dart';
import 'post_details_controller.dart';

final similarPostsProvider =
    FutureProvider.family<List<Post>, PostDetailsArgs>((ref, args) async {
  final source = args.initialPost ??
      await ref.watch(postDetailsControllerProvider(args).future);
  if (source == null) return const [];
  final tags = similarTagsFor(source);
  if (tags.isEmpty) return const [];
  final result = await ref.watch(feedServiceProvider).refresh(
        tags: tags,
        limit: 60,
      );
  if (result is! Success<List<Post>>) return const [];
  return result.data
      .where((post) => post.cacheKey != source.cacheKey)
      .toList(growable: false);
});

class SimilarPostsScreen extends ConsumerWidget {
  const SimilarPostsScreen({
    required this.providerId,
    required this.postId,
    this.initialPost,
    super.key,
  });

  final String providerId;
  final String postId;
  final Post? initialPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = PostDetailsArgs(
      providerId: providerId,
      postId: postId,
      initialPost: initialPost,
    );
    final source = ref.watch(postDetailsControllerProvider(args));
    final similar = ref.watch(similarPostsProvider(args));
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final favorites = ref.watch(favoriteKeysProvider).value ?? <String>{};
    final viewed = ref.watch(viewedKeysProvider).value ?? <String>{};
    final columns = Responsive.isMobile(context)
        ? settings.mobileColumns
        : settings.desktopColumns;

    return AdaptiveScaffold(
      title: 'Similar',
      body: source.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (post) {
          final tags = post == null ? const <String>[] : similarTagsFor(post);
          return similar.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorView(message: error.toString()),
            data: (posts) {
              if (tags.isEmpty || posts.isEmpty) {
                return const EmptyView(title: 'No similar posts yet');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags.take(8)) Chip(label: Text(tag)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PostMasonryGrid(
                      posts: posts,
                      columns: columns,
                      blurExplicit: settings.blurExplicitContent,
                      showBadges: settings.showPostBadges,
                      nsfwEnabled: settings.nsfwEnabled,
                      favoriteKeys: favorites,
                      viewedKeys: viewed,
                      onOpen: (post) => context.push(
                        '/post/${post.providerId}/${post.id}',
                        extra: post,
                      ),
                      onFavorite: (post) =>
                          _toggleFavorite(ref, post, favorites),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorite(
    WidgetRef ref,
    Post post,
    Set<String> favoriteKeys,
  ) async {
    if (favoriteKeys.contains(post.cacheKey)) {
      await ref
          .read(favoriteServiceProvider)
          .removeFavorite(post.id, post.providerId);
    } else {
      await ref.read(favoriteServiceProvider).addFavorite(post);
    }
    ref.invalidate(favoriteKeysProvider);
    ref.invalidate(viewedControllerProvider);
  }
}
