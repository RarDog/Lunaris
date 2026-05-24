import 'package:flutter/material.dart';

import '../../../../backend/backend.dart';
import '../../../../shared/widgets/provider_status_badge.dart';

class ProviderHealthTile extends StatelessWidget {
  const ProviderHealthTile({
    required this.config,
    required this.health,
    required this.diagnostics,
    required this.onCheck,
    super.key,
  });

  final ContentProviderConfig config;
  final ProviderHealth? health;
  final ProviderDiagnostics? diagnostics;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(config.name),
        subtitle: Text(
          [
            '${config.apiType} | ${config.enabled ? 'enabled' : 'disabled'} | priority ${config.priority}',
            if (health != null) 'Ping ${health!.pingMs} ms',
            if (health?.apiVersion != null) 'API ${health!.apiVersion}',
            if (health?.lastCheckedAt != null)
              'Checked ${health!.lastCheckedAt}',
            if (diagnostics != null)
              'Last search: ${diagnostics!.lastResultCount} posts at ${diagnostics!.lastSearchAt}',
            if (diagnostics?.lastErrorMessage != null)
              diagnostics!.lastErrorMessage!,
            if (health?.errorMessage != null) health!.errorMessage!,
          ].join('\n'),
          maxLines: 7,
          overflow: TextOverflow.ellipsis,
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
