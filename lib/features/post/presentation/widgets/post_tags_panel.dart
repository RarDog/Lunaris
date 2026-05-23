import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../backend/backend.dart';
import '../../../../shared/widgets/tag_chip.dart';

class PostTagsPanel extends StatelessWidget {
  const PostTagsPanel({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final groups = _groups(post);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Text(
              _label(entry.key),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in entry.value.take(80))
                TagChip(
                  tag: tag,
                  onTap: () =>
                      context.go('/?q=${Uri.encodeQueryComponent(tag)}'),
                ),
            ],
          ),
        ],
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
        ordered.putIfAbsent(entry.key, () => entry.value);
      }
      return ordered;
    }
    return {'general': post.tags};
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
