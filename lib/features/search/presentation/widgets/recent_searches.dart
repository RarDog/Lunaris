import 'package:flutter/material.dart';

import '../../../../backend/backend.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({required this.items, required this.onTap, super.key});

  final List<SearchHistory> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('No recent searches');
    return Column(
      children: [
        for (final item in items)
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(item.query),
            subtitle:
                Text('${item.tags.join(' ')} · ${item.resultCount} results'),
            onTap: () => onTap(item.query),
          ),
      ],
    );
  }
}
