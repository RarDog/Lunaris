import 'package:flutter/material.dart';

import '../../../../backend/backend.dart';
import '../../../../shared/widgets/provider_status_badge.dart';

class ProviderHealthTile extends StatelessWidget {
  const ProviderHealthTile({
    required this.config,
    required this.health,
    required this.onCheck,
    super.key,
  });

  final ContentProviderConfig config;
  final ProviderHealth? health;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(config.name),
        subtitle: Text(
          [
            if (health != null) 'Ping ${health!.pingMs} ms',
            if (health?.lastCheckedAt != null)
              'Checked ${health!.lastCheckedAt}',
            if (health?.errorMessage != null) health!.errorMessage!,
          ].join('\n'),
        ),
        leading: ProviderStatusBadge(health: health),
        trailing: IconButton(
          tooltip: 'Check',
          onPressed: onCheck,
          icon: const Icon(Icons.network_check_rounded),
        ),
      ),
    );
  }
}
