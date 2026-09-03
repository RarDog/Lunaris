import 'package:flutter/material.dart';

import '../../../../backend/backend.dart';

class RecentSearches extends StatefulWidget {
  const RecentSearches({required this.items, required this.onTap, super.key});

  final List<SearchHistory> items;
  final ValueChanged<String> onTap;

  @override
  State<RecentSearches> createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<RecentSearches> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const Text('No recent searches');
    final visibleItems =
        _expanded ? widget.items : widget.items.take(30).toList();
    return Column(
      children: [
        for (final item in visibleItems)
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(item.query),
            subtitle:
                Text('${item.tags.join(' ')} - ${item.resultCount} results'),
            onTap: () => widget.onTap(item.query),
          ),
        if (widget.items.length > 30)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(
              _expanded ? Icons.unfold_less_rounded : Icons.unfold_more_rounded,
            ),
            label: Text(
              _expanded
                  ? 'Show latest 30'
                  : 'Show all ${widget.items.length} searches',
            ),
          ),
      ],
    );
  }
}
