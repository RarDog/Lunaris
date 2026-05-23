import 'package:flutter/material.dart';

import '../../backend/backend.dart';

class ProviderStatusBadge extends StatelessWidget {
  const ProviderStatusBadge({required this.health, super.key});

  final ProviderHealth? health;

  @override
  Widget build(BuildContext context) {
    final status = health?.status ?? ProviderStatus.unknown;
    final color = switch (status) {
      ProviderStatus.online => Colors.green,
      ProviderStatus.offline => Colors.red,
      ProviderStatus.unknown => Colors.grey,
    };
    return Chip(
      avatar: Icon(Icons.circle, color: color, size: 10),
      label: Text(status.name),
      visualDensity: VisualDensity.compact,
    );
  }
}
