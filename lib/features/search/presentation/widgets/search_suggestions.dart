import 'package:flutter/material.dart';

import '../../../../backend/backend.dart';

class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({
    required this.suggestions,
    required this.onTap,
    super.key,
  });

  final List<TagSuggestion> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final suggestion in suggestions)
          ActionChip(
            avatar: Icon(
              Icons.tag_rounded,
              size: 16,
              color: _categoryColor(suggestion.category, scheme),
            ),
            label: Text(
              suggestion.postCount > 0
                  ? '${suggestion.name} (${_compactCount(suggestion.postCount)})'
                  : suggestion.name,
            ),
            onPressed: () => onTap(suggestion.name),
          ),
      ],
    );
  }

  Color _categoryColor(TagCategory category, ColorScheme scheme) {
    return switch (category) {
      TagCategory.artist => const Color(0xFFFF5252),
      TagCategory.character => const Color(0xFF66BB6A),
      TagCategory.copyright => const Color(0xFFBA68C8),
      TagCategory.species => const Color(0xFF4FC3F7),
      TagCategory.meta => const Color(0xFF90A4AE),
      TagCategory.general || TagCategory.unknown => scheme.primary,
    };
  }

  String _compactCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }
}
