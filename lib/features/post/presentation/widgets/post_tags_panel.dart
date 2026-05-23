import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../backend/backend.dart';
import '../../../../shared/widgets/tag_chip.dart';

class PostTagsPanel extends StatelessWidget {
  const PostTagsPanel({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in post.tags.take(80))
          TagChip(
            tag: tag,
            onTap: () => context.go('/?q=${Uri.encodeQueryComponent(tag)}'),
          ),
      ],
    );
  }
}
