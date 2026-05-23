import 'dart:ui';

import 'package:flutter/material.dart';

class BlurContent extends StatelessWidget {
  const BlurContent({
    required this.enabled,
    required this.child,
    super.key,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: child,
        ),
        ColoredBox(
          color: Colors.black.withValues(alpha: 0.12),
          child: const Center(
            child: Icon(Icons.visibility_off_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
