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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.7,
        ),
      ),
      child: Text(
        rating.isEmpty ? 'unknown' : rating,
        style: const TextStyle(
          fontSize: 10.5,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
