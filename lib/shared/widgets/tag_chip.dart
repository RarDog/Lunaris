import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  const TagChip({required this.tag, this.onTap, super.key});

  final String tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ActionChip(
      onPressed: onTap,
      label: Text(tag),
      labelStyle: TextStyle(
        color: scheme.onSecondaryContainer,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: scheme.secondaryContainer.withValues(alpha: 0.62),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.65)),
      visualDensity: VisualDensity.compact,
    );
  }
}
