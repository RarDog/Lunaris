import 'package:flutter/material.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge({required this.rating, super.key});

  final String rating;

  @override
  Widget build(BuildContext context) {
    final normalized = rating.toLowerCase();
    final color = switch (normalized) {
      'safe' || 's' => Colors.green,
      'questionable' || 'q' => Colors.orange,
      'explicit' || 'e' => Colors.red,
      _ => Colors.blueGrey,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          rating.isEmpty ? 'unknown' : rating,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      ),
    );
  }
}
