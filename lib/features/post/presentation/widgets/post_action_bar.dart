import 'package:flutter/material.dart';

class PostActionBar extends StatelessWidget {
  const PostActionBar({
    required this.onFavorite,
    required this.onCollection,
    required this.onOpen,
    required this.onCopy,
    required this.isFavorite,
    this.onDownload,
    super.key,
  });

  final VoidCallback onFavorite;
  final VoidCallback onCollection;
  final VoidCallback onOpen;
  final VoidCallback onCopy;
  final bool isFavorite;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: onFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          ),
          label: Text(isFavorite ? 'Unfavorite' : 'Favorite'),
        ),
        FilledButton.tonalIcon(
          onPressed: onCollection,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Collection'),
        ),
        IconButton.filledTonal(
          tooltip: 'Open original',
          onPressed: onOpen,
          icon: const Icon(Icons.open_in_new_rounded),
        ),
        IconButton.filledTonal(
          tooltip: 'Copy link',
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded),
        ),
        if (onDownload != null)
          IconButton.filledTonal(
            tooltip: 'Download',
            onPressed: onDownload,
            icon: const Icon(Icons.download_rounded),
          ),
      ],
    );
  }
}
