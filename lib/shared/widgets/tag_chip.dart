import 'package:flutter/material.dart';

import '../../backend/models/tag_suggestion.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    required this.tag,
    this.category,
    this.group,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final String tag;
  final TagCategory? category;
  final String? group;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  TagCategory get _resolvedCategory {
    if (category != null) return category!;
    final g = (group ?? '').toLowerCase();
    return switch (g) {
      'artist' => TagCategory.artist,
      'character' => TagCategory.character,
      'copyright' => TagCategory.copyright,
      'species' => TagCategory.species,
      'meta' => TagCategory.meta,
      'general' => TagCategory.general,
      _ => tagCategoryFromString(g),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = _resolvedCategory;

    final (Color baseColor, Color textColor) = _colorsForCategory(cat, scheme, isDark);

    final chipWidget = Container(
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.40 : 0.28),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  tag,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (onLongPress == null) return chipWidget;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: chipWidget,
    );
  }

  static (Color, Color) _colorsForCategory(
    TagCategory cat,
    ColorScheme scheme,
    bool isDark,
  ) {
    return switch (cat) {
      TagCategory.artist => (
          const Color(0xFFFF4757), // e621 / Gelbooru red/coral
          isDark ? const Color(0xFFFF6B81) : const Color(0xFFD63031),
        ),
      TagCategory.character => (
          const Color(0xFF2ED573), // Vibrant character green
          isDark ? const Color(0xFF7BED9F) : const Color(0xFF10AC84),
        ),
      TagCategory.copyright => (
          const Color(0xFFA55EEA), // Classic anime series purple
          isDark ? const Color(0xFFD980FA) : const Color(0xFF8854D0),
        ),
      TagCategory.species => (
          const Color(0xFFFFA502), // e621 species amber/orange
          isDark ? const Color(0xFFFFC048) : const Color(0xFFE67E22),
        ),
      TagCategory.meta => (
          const Color(0xFF1E90FF), // Meta / format cyan / ice blue
          isDark ? const Color(0xFF70A1FF) : const Color(0xFF0984E3),
        ),
      TagCategory.general || TagCategory.unknown => (
          isDark ? scheme.primary : scheme.primary,
          isDark ? scheme.onSurface : scheme.onSurface,
        ),
    };
  }
}

