import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../backend/backend.dart';
import '../../../../shared/widgets/tag_chip.dart';

class PostTagsPanel extends StatefulWidget {
  const PostTagsPanel({required this.post, super.key});

  final Post post;

  @override
  State<PostTagsPanel> createState() => _PostTagsPanelState();
}

class _PostTagsPanelState extends State<PostTagsPanel> {
  final _expandedGroups = <String>{};

  @override
  Widget build(BuildContext context) {
    final groups = _groups(widget.post);
    if (groups.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries)
          _TagGroupBlock(
            label: _label(entry.key),
            tags: entry.value,
            expanded: _expandedGroups.contains(entry.key),
            onToggleExpanded: () {
              setState(() {
                if (!_expandedGroups.add(entry.key)) {
                  _expandedGroups.remove(entry.key);
                }
              });
            },
            onTap: (tag) => context.go('/?q=${Uri.encodeQueryComponent(tag)}'),
          ),
      ],
    );
  }

  Map<String, List<String>> _groups(Post post) {
    if (post.tagGroups.isNotEmpty) {
      final ordered = <String, List<String>>{};
      for (final key in [
        'artist',
        'character',
        'copyright',
        'species',
        'meta',
        'general',
      ]) {
        final tags = post.tagGroups[key];
        if (tags != null && tags.isNotEmpty) ordered[key] = tags;
      }
      for (final entry in post.tagGroups.entries) {
        if (entry.value.isNotEmpty) {
          ordered.putIfAbsent(entry.key, () => entry.value);
        }
      }
      return ordered;
    }
    return post.tags.isEmpty ? const {} : {'general': post.tags};
  }

  String _label(String key) {
    return switch (key) {
      'artist' => 'Artist',
      'character' => 'Character',
      'copyright' => 'Copyright / Title',
      'species' => 'Species',
      'meta' => 'Meta',
      'general' => 'General',
      _ => 'Other',
    };
  }
}

class _TagGroupBlock extends StatelessWidget {
  const _TagGroupBlock({
    required this.label,
    required this.tags,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onTap,
  });

  static const _collapsedLimit = 36;

  final String label;
  final List<String> tags;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final visibleTags = expanded || tags.length <= _collapsedLimit
        ? tags
        : tags.take(_collapsedLimit).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: 8),
              Text(
                '${tags.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in visibleTags)
                TagChip(
                  tag: tag,
                  onTap: () => onTap(tag),
                ),
              if (tags.length > _collapsedLimit)
                ActionChip(
                  avatar: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                  ),
                  label: Text(
                    expanded ? 'Collapse' : '+${tags.length - _collapsedLimit}',
                  ),
                  onPressed: onToggleExpanded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
