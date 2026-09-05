import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../backend/models/post.dart';

class PostRelationsCard extends StatelessWidget {
  const PostRelationsCard({
    required this.post,
    required this.onOpenPostId,
    super.key,
  });

  final Post post;
  final ValueChanged<String> onOpenPostId;

  @override
  Widget build(BuildContext context) {
    if (!post.hasRelations) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';

    final parentId = post.parentId;
    final children = post.childrenIds;

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
              Icon(
                Icons.copy_all_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isRu ? 'Связанные посты и версии' : 'Variations & Relations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(parentId != null ? 1 : 0) + children.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
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
              if (parentId != null)
                _RelationPill(
                  icon: Icons.north_west_rounded,
                  label: isRu ? 'Родительский арт #$parentId' : 'Parent #$parentId',
                  color: const Color(0xFF0077EE),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onOpenPostId(parentId);
                  },
                ),
              for (final childId in children)
                _RelationPill(
                  icon: Icons.style_rounded,
                  label: isRu ? 'Версия #$childId' : 'Variant #$childId',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onOpenPostId(childId);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelationPill extends StatelessWidget {
  const _RelationPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.35 : 0.25),
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
