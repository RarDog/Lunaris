import 'package:flutter/material.dart';

import '../../backend/backend.dart';

class ProviderStatusBadge extends StatelessWidget {
  const ProviderStatusBadge({
    required this.health,
    this.compact = false,
    super.key,
  });

  final ProviderHealth? health;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = health?.status ?? ProviderStatus.unknown;

    final (color, labelRu, labelEn) = switch (status) {
      ProviderStatus.online => (
          const Color(0xFF10B981), // Emerald
          'Онлайн',
          'Online',
        ),
      ProviderStatus.offline => (
          const Color(0xFFEF4444), // Crimson Red
          'Офлайн',
          'Offline',
        ),
      ProviderStatus.unknown => (
          const Color(0xFF94A3B8), // Slate
          'Не проверен',
          'Unknown',
        ),
    };

    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';
    final label = isRu ? labelRu : labelEn;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.45 : 0.32),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 5,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
