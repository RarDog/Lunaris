import 'package:flutter/material.dart';

import '../../../../backend/backend.dart';

class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions(
      {required this.suggestions, required this.onTap, super.key});

  final List<TagSuggestion> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final suggestion in suggestions)
          ActionChip(
            label: Text('${suggestion.name} · ${suggestion.categoryLabel}'),
            onPressed: () => onTap(suggestion.name),
          ),
      ],
    );
  }
}
