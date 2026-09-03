import 'package:flutter/material.dart';

class PostActionBar extends StatelessWidget {
  const PostActionBar({
    required this.onFavorite,
    required this.onCollection,
    required this.onOpen,
    required this.onCopy,
    required this.isFavorite,
    this.onOpenSource,
    this.onDownload,
    this.onDeleteLocalFile,
    this.onShare,
    this.downloaded = false,
    this.labels,
    this.onSimilar,
    this.onHide,
    super.key,
  });

  final VoidCallback onFavorite;
  final VoidCallback onCollection;
  final VoidCallback onOpen;
  final VoidCallback onCopy;
  final VoidCallback? onOpenSource;
  final bool isFavorite;
  final VoidCallback? onDownload;
  final VoidCallback? onDeleteLocalFile;
  final VoidCallback? onShare;
  final VoidCallback? onSimilar;
  final VoidCallback? onHide;
  final bool downloaded;
  final PostActionLabels? labels;

  @override
  Widget build(BuildContext context) {
    final text = labels ?? const PostActionLabels();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: onFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          ),
          label: Text(isFavorite ? text.unfavorite : text.favorite),
        ),
        FilledButton.tonalIcon(
          onPressed: onCollection,
          icon: const Icon(Icons.add_rounded),
          label: Text(text.collection),
        ),
        if (onSimilar != null)
          FilledButton.tonalIcon(
            onPressed: onSimilar,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(text.similar),
          ),
        IconButton.filledTonal(
          tooltip: text.openOriginal,
          onPressed: onOpen,
          icon: const Icon(Icons.open_in_new_rounded),
        ),
        if (onOpenSource != null)
          IconButton.filledTonal(
            tooltip: text.openSource,
            onPressed: onOpenSource,
            icon: const Icon(Icons.article_rounded),
          ),
        IconButton.filledTonal(
          tooltip: text.copyLink,
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded),
        ),
        if (onDownload != null)
          IconButton.filledTonal(
            tooltip: text.download,
            onPressed: onDownload,
            icon: Icon(
              downloaded ? Icons.download_done_rounded : Icons.download_rounded,
            ),
          ),
        if (downloaded && onDeleteLocalFile != null)
          IconButton.filledTonal(
            tooltip: text.deleteLocalFile,
            onPressed: onDeleteLocalFile,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        if (onHide != null)
          IconButton.filledTonal(
            tooltip: text.hidePost,
            onPressed: onHide,
            icon: const Icon(Icons.visibility_off_rounded),
          ),
        if (onShare != null)
          IconButton.filledTonal(
            tooltip: text.share,
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded),
          ),
      ],
    );
  }
}

class PostActionLabels {
  const PostActionLabels({
    this.favorite = 'Favorite',
    this.unfavorite = 'Unfavorite',
    this.collection = 'Collection',
    this.similar = 'Similar',
    this.openOriginal = 'Open original',
    this.openSource = 'Open source/page',
    this.copyLink = 'Copy link',
    this.download = 'Download',
    this.deleteLocalFile = 'Delete local file',
    this.hidePost = 'Hide post locally',
    this.share = 'Share',
  });

  final String favorite;
  final String unfavorite;
  final String collection;
  final String similar;
  final String openOriginal;
  final String openSource;
  final String copyLink;
  final String download;
  final String deleteLocalFile;
  final String hidePost;
  final String share;
}
