import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  const TagChip({required this.tag, this.onTap, super.key});

  final String tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(tag),
      visualDensity: VisualDensity.compact,
    );
  }
}
