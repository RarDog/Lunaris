import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../backend/models/post.dart';
import '../../../../backend/providers/e621_provider.dart';
import 'e621_pool_sheet.dart';

class PostPoolsCard extends StatelessWidget {
  const PostPoolsCard({
    required this.post,
    required this.provider,
    required this.onOpenComic,
    required this.onOpenPostId,
    super.key,
  });

  final Post post;
  final E621Provider provider;
  final void Function(String poolId, Post currentPost, [String? targetId])
      onOpenComic;
  final ValueChanged<String> onOpenPostId;

  @override
  Widget build(BuildContext context) {
    if (!post.hasPools) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';
    final pools = post.poolIds;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.70)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.40),
          width: 1.1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: Color(0xFF0077EE),
              ),
              const SizedBox(width: 8),
              Text(
                isRu ? 'Входит в комикс / серию' : 'Part of Series / Pool',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0055AA).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pools.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0077EE),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final poolId in pools)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onOpenComic(poolId, post);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0055AA), Color(0xFF0077EE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0055AA)
                                    .withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_stories_rounded,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 7),
                              Text(
                                isRu
                                    ? 'Читать весь комикс (#$poolId)'
                                    : 'Read Full Comic (#$poolId)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_rounded,
                                  size: 13, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton.filledTonal(
                      tooltip: isRu ? 'Все страницы' : 'All pages',
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        E621PoolSheet.show(
                          context,
                          currentPost: post,
                          poolId: poolId,
                          provider: provider,
                          onSelectPostId: (targetId) =>
                              onOpenComic(poolId, post, targetId),
                        );
                      },
                      icon: const Icon(Icons.grid_view_rounded, size: 16),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
