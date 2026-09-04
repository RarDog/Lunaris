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
    this.isDownloading = false,
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
  final bool isDownloading;
  final PostActionLabels? labels;

  void _showMoreActions(BuildContext context, PostActionLabels text) {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Copy Link
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.copy_rounded, size: 20),
                ),
                title: Text(text.copyLink),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onCopy();
                },
              ),
              // Open Original in Browser
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.open_in_new_rounded, size: 20),
                ),
                title: Text(text.openOriginal),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onOpen();
                },
              ),
              // Open Source Page
              if (onOpenSource != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.article_rounded, size: 20),
                  ),
                  title: Text(text.openSource),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onOpenSource!();
                  },
                ),
              // Find Similar
              if (onSimilar != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 20, color: scheme.primary),
                  ),
                  title: Text(text.similar),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onSimilar!();
                  },
                ),
              const Divider(height: 16),
              // Delete Local File (if downloaded)
              if (downloaded && onDeleteLocalFile != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        size: 20, color: scheme.error),
                  ),
                  title: Text(
                    text.deleteLocalFile,
                    style: TextStyle(color: scheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onDeleteLocalFile!();
                  },
                ),
              // Hide Post
              if (onHide != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.visibility_off_rounded, size: 20),
                  ),
                  title: Text(text.hidePost),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onHide!();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = labels ?? const PostActionLabels();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Favorite / Like Button
          Expanded(
            flex: 3,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: isFavorite
                    ? Colors.redAccent.withValues(alpha: 0.18)
                    : scheme.secondaryContainer.withValues(alpha: 0.5),
                foregroundColor:
                    isFavorite ? Colors.redAccent : scheme.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onFavorite,
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: isFavorite ? Colors.redAccent : null,
              ),
              label: Text(
                isFavorite ? text.unfavorite : text.favorite,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Download Button with Status
          if (onDownload != null) ...[
            _ActionButton(
              tooltip: downloaded ? text.downloaded : text.download,
              icon: isDownloading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    )
                  : Icon(
                      downloaded
                          ? Icons.offline_pin_rounded
                          : Icons.download_rounded,
                      color: downloaded ? Colors.green : null,
                      size: 22,
                    ),
              onTap: onDownload!,
            ),
            const SizedBox(width: 6),
          ],

          // Add to Collection
          _ActionButton(
            tooltip: text.collection,
            icon: const Icon(Icons.bookmark_add_rounded, size: 22),
            onTap: onCollection,
          ),
          const SizedBox(width: 6),

          // Share
          if (onShare != null) ...[
            _ActionButton(
              tooltip: text.share,
              icon: const Icon(Icons.share_rounded, size: 22),
              onTap: onShare!,
            ),
            const SizedBox(width: 6),
          ],

          // More Options Bottom Sheet
          _ActionButton(
            tooltip: text.more,
            icon: const Icon(Icons.more_horiz_rounded, size: 22),
            onTap: () => _showMoreActions(context, text),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: icon,
      style: IconButton.styleFrom(
        backgroundColor: scheme.secondaryContainer.withValues(alpha: 0.35),
        foregroundColor: scheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(44, 44),
      ),
    );
  }
}

class PostActionLabels {
  const PostActionLabels({
    this.favorite = 'Favorite',
    this.unfavorite = 'Saved',
    this.collection = 'Collection',
    this.similar = 'Similar',
    this.openOriginal = 'Open original',
    this.openSource = 'Open source/page',
    this.copyLink = 'Copy link',
    this.download = 'Download',
    this.downloaded = 'Downloaded',
    this.deleteLocalFile = 'Delete local file',
    this.hidePost = 'Hide post locally',
    this.share = 'Share',
    this.more = 'More',
  });

  final String favorite;
  final String unfavorite;
  final String collection;
  final String similar;
  final String openOriginal;
  final String openSource;
  final String copyLink;
  final String download;
  final String downloaded;
  final String deleteLocalFile;
  final String hidePost;
  final String share;
  final String more;
}
