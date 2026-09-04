import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_strings.dart';
import '../../../../backend/models/cloud_media_link.dart';
import '../../../../backend/models/creator_link.dart';
import '../../../../shared/widgets/formatted_content_text.dart';

class CloudMirrorsCard extends StatelessWidget {
  const CloudMirrorsCard({
    super.key,
    required this.links,
    required this.strings,
    this.commentary,
    this.onPlayStream,
    this.onDownloadStream,
    this.initiallyExpanded = false,
  });

  final List<CloudMediaLink> links;
  final AppStrings strings;
  final String? commentary;
  final ValueChanged<String>? onPlayStream;
  final ValueChanged<String>? onDownloadStream;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty && (commentary == null || commentary!.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final detectedPassword = links
        .map((l) => l.detectedPassword)
        .whereType<String>()
        .firstWhere((p) => p.isNotEmpty, orElse: () => '');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(
          Icons.cloud_sync_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                strings.ru
                    ? 'Облачные диски и зеркала (${links.length})'
                    : 'Cloud Mirrors & Drives (${links.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (links.any((l) => l.isStreamable)) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded,
                        size: 13, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      strings.ru ? 'Плеер' : 'Stream',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        children: [
          // Archive Password Banner
          if (detectedPassword.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: strings.ru ? 'Пароль к архиву: ' : 'Archive Password: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: detectedPassword,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    tooltip: strings.ru ? 'Копировать пароль' : 'Copy Password',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: detectedPassword));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            strings.ru
                                ? 'Пароль скопирован: $detectedPassword'
                                : 'Password copied: $detectedPassword',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Links list
          if (links.isNotEmpty) ...[
            ...links.map((link) => _buildLinkTile(context, link, strings)),
          ],

          // Commentary / Description
          if (commentary != null && commentary!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              height: 1,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.notes_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  strings.ru ? 'Описание от автора' : 'Artist Commentary',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FormattedContentText(
              text: commentary!.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.45,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Builder(
              builder: (context) {
                final creatorLinks = CreatorLink.extractLinks(commentary);
                if (creatorLinks.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CreatorLinkChips(
                    links: creatorLinks,
                    title: strings.ru ? 'Ссылки автора' : 'Author Links',
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context,
    CloudMediaLink link,
    AppStrings strings,
  ) {
    final theme = Theme.of(context);
    final brandColor = link.brandColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: brandColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: brandColor.withValues(alpha: 0.35)),
                ),
                child: Icon(link.iconData, size: 20, color: brandColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            link.serviceName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (link.isFolder)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              strings.ru ? 'Папка' : 'Folder',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      link.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Play button (if streamable)
              if (link.isStreamable && onPlayStream != null) ...[
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text(strings.ru ? 'Смотреть' : 'Play'),
                  onPressed: () {
                    final target = link.directStreamUrl ?? link.url;
                    onPlayStream!(target);
                  },
                ),
                const SizedBox(width: 8),
              ],
              // Download button (if direct streamable and callback exists)
              if (link.isStreamable &&
                  link.directStreamUrl != null &&
                  onDownloadStream != null) ...[
                IconButton.filledTonal(
                  visualDensity: VisualDensity.compact,
                  tooltip: strings.download,
                  icon: const Icon(Icons.download_rounded, size: 16),
                  onPressed: () => onDownloadStream!(link.directStreamUrl!),
                ),
                const SizedBox(width: 8),
              ],
              // Copy link button
              IconButton.outlined(
                visualDensity: VisualDensity.compact,
                tooltip: strings.copyLink,
                icon: const Icon(Icons.copy_rounded, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: link.url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        strings.ru
                            ? 'Ссылка скопирована: ${link.serviceName}'
                            : 'Link copied: ${link.serviceName}',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              // Open in browser / app button
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: Text(strings.ru ? 'Открыть' : 'Open'),
                onPressed: () => launchUrl(
                  Uri.parse(link.url),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
