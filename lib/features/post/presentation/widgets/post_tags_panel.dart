import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
          _HorizontalTagRow(
            tags: entry.value.take(120).toList(),
            onTap: (tag) => context.go('/?q=${Uri.encodeQueryComponent(tag)}'),
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

class _HorizontalTagRow extends StatefulWidget {
  const _HorizontalTagRow({
    required this.tags,
    required this.onTap,
  });

  final List<String> tags;
  final ValueChanged<String> onTap;

  @override
  State<_HorizontalTagRow> createState() => _HorizontalTagRowState();
}

class _HorizontalTagRowState extends State<_HorizontalTagRow> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Listener(
        onPointerSignal: (event) {
          if (event is! PointerScrollEvent || !_controller.hasClients) return;
          final target = (_controller.offset + event.scrollDelta.dy)
              .clamp(0.0, _controller.position.maxScrollExtent)
              .toDouble();
          _controller.jumpTo(target);
        },
        child: ListView.separated(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          primary: false,
          itemCount: widget.tags.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => TagChip(
            tag: widget.tags[index],
            onTap: () => widget.onTap(widget.tags[index]),
          ),
        ),
      ),
    );
  }
}
