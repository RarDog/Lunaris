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
    required this.mediaQualityMode,
    required this.onOpen,
    required this.onFavorite,
    this.onAddToCollection,
    this.onPreview,
    this.onHide,
    this.onToggleSelected,
    this.selectionMode = false,
    this.selectedKeys = const {},
    this.favoriteKeys = const {},
    this.viewedKeys = const {},
    this.downloadedKeys = const {},
    this.loading = false,
    this.controller,
    this.gridMode = 'masonry',
    super.key,
  });

  final List<Post> posts;
  final int columns;
  final bool blurExplicit;
  final bool showBadges;
  final bool nsfwEnabled;
  final MediaQualityMode mediaQualityMode;
  final ValueChanged<Post> onOpen;
  final ValueChanged<Post> onFavorite;
  final ValueChanged<Post>? onAddToCollection;
  final ValueChanged<Post>? onPreview;
  final ValueChanged<Post>? onHide;
  final ValueChanged<Post>? onToggleSelected;
  final bool selectionMode;
  final Set<String> selectedKeys;
  final Set<String> favoriteKeys;
  final Set<String> viewedKeys;
  final Set<String> downloadedKeys;
  final bool loading;
  final ScrollController? controller;
  final String gridMode;

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    final pad = EdgeInsets.all(mobile ? 8 : 16);
    final spacing = mobile ? 8.0 : 12.0;

    Widget buildCard(Post post) {
      return PostCard(
        post: post,
        blurExplicit: blurExplicit && !nsfwEnabled,
        showBadges: showBadges,
        isFavorite: favoriteKeys.contains(post.cacheKey),
        isViewed: viewedKeys.contains(post.cacheKey),
        isDownloaded: downloadedKeys.contains(post.cacheKey),
        mediaQualityMode: mediaQualityMode,
        onOpen: () => onOpen(post),
        onFavorite: () => onFavorite(post),
        onPreview: onPreview == null ? null : () => onPreview!(post),
        onHide: onHide == null ? null : () => onHide!(post),
        selectionMode: selectionMode,
        selected: selectedKeys.contains(post.cacheKey),
        onToggleSelected:
            onToggleSelected == null ? null : () => onToggleSelected!(post),
        onAddToCollection:
            onAddToCollection == null ? null : () => onAddToCollection!(post),
      );
    }

    if (gridMode == 'grid') {
      // Uniform square grid
      return GridView.builder(
        controller: controller,
        padding: pad,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: 1.0,
        ),
        itemCount: posts.length + (loading ? columns : 0),
        itemBuilder: (context, index) {
          if (index >= posts.length) return const LoadingSkeleton();
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: buildCard(posts[index]),
              ),
            ),
          );
        },
      );
    }

    if (gridMode == 'list') {
      // Vertical list with larger cards
      return ListView.separated(
        controller: controller,
        padding: pad,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemCount: posts.length + (loading ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= posts.length) return const LoadingSkeleton();
          return buildCard(posts[index]);
        },
      );
    }

    // Default: masonry
    return MasonryGridView.count(
      controller: controller,
      padding: pad,
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      itemCount: posts.length + (loading ? columns : 0),
      itemBuilder: (context, index) {
        if (index >= posts.length) return const LoadingSkeleton();
        return buildCard(posts[index]);
      },
    );
  }
}
