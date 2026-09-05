import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../backend/backend.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    required this.config,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ContentProviderConfig config;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';
    final (engineColor, engineIcon, engineTitle) = _engineInfo(config.apiType);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.30)
                : engineColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: engineColor.withValues(alpha: isDark ? 0.05 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      theme.colorScheme.surfaceContainerHigh
                          .withValues(alpha: config.enabled ? 0.65 : 0.35),
                      theme.colorScheme.surfaceContainerLow
                          .withValues(alpha: config.enabled ? 0.45 : 0.20),
                    ]
                  : [
                      Colors.white
                          .withValues(alpha: config.enabled ? 0.90 : 0.60),
                      Colors.white
                          .withValues(alpha: config.enabled ? 0.75 : 0.45),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? (config.enabled
                      ? engineColor.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.08))
                  : (config.enabled
                      ? Colors.white.withValues(alpha: 0.90)
                      : Colors.white.withValues(alpha: 0.50)),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Icon squircle + Name & details + Switch
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Engine Icon Squircle Badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: config.enabled
                            ? [
                                engineColor,
                                engineColor.withValues(alpha: 0.80),
                              ]
                            : [
                                Colors.grey.shade600,
                                Colors.grey.shade700,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        if (config.enabled)
                          BoxShadow(
                            color: engineColor.withValues(alpha: 0.38),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        engineIcon,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Sub-details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                config.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: config.enabled
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // Engine badge
                            _GlassPill(
                              label: engineTitle,
                              color: engineColor,
                              isDark: isDark,
                            ),
                            // Priority badge
                            _GlassPill(
                              label: '${isRu ? 'Приоритет' : 'Priority'} ${config.priority}',
                              color: theme.colorScheme.primary,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Switch
                  Transform.scale(
                    scale: 0.9,
                    child: Switch.adaptive(
                      value: config.enabled,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        onToggle(val);
                      },
                      activeThumbColor: engineColor,
                      activeTrackColor: engineColor.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Row 2: Base URL glass chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.20)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        config.baseUrl,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Row 3: Action Buttons (Edit & Delete)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit Action Button
                  _GlassActionButton(
                    icon: Icons.edit_rounded,
                    label: isRu ? 'Изменить' : 'Edit',
                    color: theme.colorScheme.primary,
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onEdit();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Delete Action Button
                  _GlassActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: isRu ? 'Удалить' : 'Delete',
                    color: const Color(0xFFEF4444),
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onDelete();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static (Color, IconData, String) _engineInfo(String apiType) {
    return switch (apiType.toLowerCase()) {
      'gelbooru' => (
          const Color(0xFF10B981),
          Icons.image_search_rounded,
          'Gelbooru',
        ),
      'rule34' => (
          const Color(0xFF84CC16),
          Icons.photo_library_rounded,
          'Rule34',
        ),
      'paheal' => (
          const Color(0xFFF97316),
          Icons.filter_hdr_rounded,
          'Paheal HTML',
        ),
      'realbooru_html' => (
          const Color(0xFFEAB308),
          Icons.camera_alt_rounded,
          'Realbooru HTML',
        ),
      'danbooru' => (
          const Color(0xFF3B82F6),
          Icons.auto_awesome_rounded,
          'Danbooru',
        ),
      'moebooru' => (
          const Color(0xFF8B5CF6),
          Icons.face_retouching_natural_rounded,
          'Moebooru',
        ),
      'e621' => (
          const Color(0xFFF59E0B),
          Icons.pets_rounded,
          'e621 / e926',
        ),
      _ => (
          const Color(0xFF6366F1),
          Icons.hub_rounded,
          apiType.isEmpty ? 'Custom' : apiType,
        ),
    };
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.label,
    required this.color,
    required this.isDark,
  });

  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.32 : 0.22),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
