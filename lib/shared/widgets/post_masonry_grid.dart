import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../app/responsive.dart';
import '../../backend/backend.dart';
import 'loading_skeleton.dart';
import 'post_card.dart';

class PostMasonryGrid extends StatelessWidget {
  const PostMasonryGrid({
    required this.posts,
    required this.columns,
    required this.blurExplicit,
    required this.showBadges,
    required this.nsfwEnabled,
    required this.onOpen,
    required this.onFavorite,
    this.onAddToCollection,
    this.favoriteKeys = const {},
    this.loading = false,
    this.controller,
    super.key,
  });

  final List<Post> posts;
  final int columns;
  final bool blurExplicit;
  final bool showBadges;
  final bool nsfwEnabled;
  final ValueChanged<Post> onOpen;
  final ValueChanged<Post> onFavorite;
  final ValueChanged<Post>? onAddToCollection;
  final Set<String> favoriteKeys;
  final bool loading;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return MasonryGridView.count(
      controller: controller,
      padding: EdgeInsets.all(mobile ? 8 : 16),
      crossAxisCount: columns,
      mainAxisSpacing: mobile ? 8 : 12,
      crossAxisSpacing: mobile ? 8 : 12,
      itemCount: posts.length + (loading ? columns : 0),
      itemBuilder: (context, index) {
        if (index >= posts.length) return const LoadingSkeleton();
        final post = posts[index];
        return PostCard(
          post: post,
          blurExplicit: blurExplicit && !nsfwEnabled,
          showBadges: showBadges,
          isFavorite: favoriteKeys.contains(post.cacheKey),
          onOpen: () => onOpen(post),
          onFavorite: () => onFavorite(post),
          onAddToCollection:
              onAddToCollection == null ? null : () => onAddToCollection!(post),
        );
      },
    );
  }
}
