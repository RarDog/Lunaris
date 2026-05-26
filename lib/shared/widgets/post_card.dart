import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/motion.dart';
import '../../backend/backend.dart';
import 'blur_content.dart';
import 'loading_skeleton.dart';
import 'rating_badge.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    required this.post,
    required this.blurExplicit,
    required this.showBadges,
    required this.isFavorite,
    required this.isViewed,
    required this.onOpen,
    required this.onFavorite,
    this.onAddToCollection,
    this.onPreview,
    this.onHide,
    this.onToggleSelected,
    this.selectionMode = false,
    this.selected = false,
    super.key,
  });

  final Post post;
  final bool blurExplicit;
  final bool showBadges;
  final bool isFavorite;
  final bool isViewed;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onPreview;
  final VoidCallback? onHide;
  final VoidCallback? onToggleSelected;
  final bool selectionMode;
  final bool selected;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final sensitive = _isSensitive(post.rating);
    final aspect = post.width > 0 && post.height > 0
        ? post.width / post.height
        : _fallbackAspect(post.fileType);
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.selectionMode) {
            widget.onToggleSelected?.call();
            return;
          }
          widget.onOpen();
        },
        onLongPress: () {
          if (widget.selectionMode && widget.onToggleSelected != null) {
            widget.onToggleSelected!();
            return;
          }
          if (widget.onPreview != null) {
            widget.onPreview!();
            return;
          }
          widget.onToggleSelected?.call();
        },
        onSecondaryTapDown: (details) {
          showMenu<void>(
            context: context,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx,
              details.globalPosition.dy,
            ),
            items: [
              PopupMenuItem(
                onTap: widget.onOpen,
                child: const Text('Open'),
              ),
              PopupMenuItem(
                onTap: widget.onFavorite,
                child: const Text('Favorite'),
              ),
              if (widget.onAddToCollection != null)
                PopupMenuItem(
                  onTap: widget.onAddToCollection,
                  child: const Text('Add to collection'),
                ),
              if (widget.onHide != null)
                PopupMenuItem(
                  onTap: widget.onHide,
                  child: const Text('Hide post'),
                ),
            ],
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: aspect.clamp(0.28, 2.2),
                child: BlurContent(
                  enabled: widget.blurExplicit && sensitive,
                  child: CachedNetworkImage(
                    imageUrl: post.previewUrl.isNotEmpty
                        ? post.previewUrl
                        : post.sampleUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const LoadingSkeleton(),
                    errorWidget: (context, url, error) => ColoredBox(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child:
                          const Center(child: Icon(Icons.broken_image_rounded)),
                    ),
                  ),
                ),
              ),
              if (widget.showBadges) ...[
                Positioned(
                  left: 8,
                  top: 8,
                  child: _ProviderBadge(name: post.providerName),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: RatingBadge(rating: post.rating),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _MediaBadge(fileType: post.fileType),
                ),
                if (widget.isViewed)
                  const Positioned(
                    right: 8,
                    bottom: 8,
                    child: _SeenBadge(),
                  ),
              ],
              if (widget.selected)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.24),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.check_circle_rounded),
                      ),
                    ),
                  ),
                ),
              if (mobile)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _FavoriteButton(
                    isFavorite: widget.isFavorite,
                    onPressed: widget.onFavorite,
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_hovered || mobile,
                  child: AnimatedOpacity(
                    opacity: _hovered && !mobile ? 1 : 0,
                    duration: AppMotion.duration(context, 140),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.filledTonal(
                                tooltip: widget.isFavorite
                                    ? 'Remove favorite'
                                    : 'Favorite',
                                onPressed: widget.onFavorite,
                                icon: Icon(
                                  widget.isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filledTonal(
                                tooltip: 'Add to collection',
                                onPressed: widget.onAddToCollection,
                                icon: const Icon(Icons.add_rounded),
                              ),
                              if (widget.onHide != null) ...[
                                const SizedBox(width: 6),
                                IconButton.filledTonal(
                                  tooltip: 'Hide post',
                                  onPressed: widget.onHide,
                                  icon:
                                      const Icon(Icons.visibility_off_rounded),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSensitive(String rating) {
    final normalized = rating.toLowerCase();
    return normalized.startsWith('e') ||
        normalized.startsWith('q') ||
        normalized.contains('explicit') ||
        normalized.contains('questionable');
  }

  double _fallbackAspect(String fileType) {
    final normalized = fileType.toLowerCase();
    if (normalized.contains('video') || normalized.contains('webm')) {
      return 16 / 9;
    }
    if (normalized.contains('gif')) return 1;
    return 0.72;
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      visualDensity: VisualDensity.compact,
      tooltip: isFavorite ? 'Remove favorite' : 'Favorite',
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 18,
      ),
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  const _ProviderBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          name,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      ),
    );
  }
}

class _MediaBadge extends StatelessWidget {
  const _MediaBadge({required this.fileType});

  final String fileType;

  @override
  Widget build(BuildContext context) {
    final type = _type(fileType);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(type), size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              type,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String _type(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('video') ||
        value.contains('webm') ||
        value.contains('mp4')) {
      return 'video';
    }
    if (value.contains('gif')) return 'gif';
    return 'photo';
  }

  IconData _icon(String type) => switch (type) {
        'video' => Icons.play_arrow_rounded,
        'gif' => Icons.gif_box_rounded,
        _ => Icons.image_rounded,
      };
}

class _SeenBadge extends StatelessWidget {
  const _SeenBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_rounded, size: 12, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'seen',
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAddToCollectionPicker(
  BuildContext context, {
  required List<Collection> collections,
  required void Function(Collection collection) onSelected,
  required VoidCallback onCreate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.add_rounded),
          title: const Text('Create collection'),
          onTap: () {
            Navigator.pop(context);
            onCreate();
          },
        ),
        for (final collection in collections)
          ListTile(
            title: Text(collection.name),
            subtitle: Text(collection.description ?? ''),
            onTap: () {
              Navigator.pop(context);
              onSelected(collection);
            },
          ),
      ],
    ),
  );
}
