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
    final hint = ProviderQualityHint.from(
      config: config,
      health: health,
      diagnostics: diagnostics,
    );
    return Card(
      child: ExpansionTile(
        leading: ProviderStatusBadge(health: health),
        title: Text(config.name),
        subtitle: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              avatar: Icon(hint.icon, size: 16),
              label: Text(hint.label),
              visualDensity: VisualDensity.compact,
              backgroundColor: hint.color(context).withValues(alpha: 0.16),
              side:
                  BorderSide(color: hint.color(context).withValues(alpha: 0.4)),
            ),
            Text('${config.apiType} | priority ${config.priority}'),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Check',
          onPressed: onCheck,
          icon: const Icon(Icons.network_check_rounded),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              [
                '${config.enabled ? 'Enabled' : 'Disabled'} | ${config.baseUrl}',
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
            ),
          ),
        ],
      ),
    );
  }
}

class ProviderQualityHint {
  const ProviderQualityHint._(this.label, this.icon, this._color);

  final String label;
  final IconData icon;
  final Color Function(ColorScheme scheme) _color;

  Color color(BuildContext context) => _color(Theme.of(context).colorScheme);

  static ProviderQualityHint from({
    required ContentProviderConfig config,
    required ProviderHealth? health,
    required ProviderDiagnostics? diagnostics,
  }) {
    if (!config.enabled) {
      return ProviderQualityHint._(
        'Disabled',
        Icons.pause_circle_outline_rounded,
        (scheme) => scheme.outline,
      );
    }
    if (diagnostics?.lastErrorMessage != null ||
        health?.status == ProviderStatus.offline) {
      return ProviderQualityHint._(
        'Search failing',
        Icons.error_outline_rounded,
        (scheme) => scheme.error,
      );
    }
    if (diagnostics != null && diagnostics.lastResultCount == 0) {
      return ProviderQualityHint._(
        'No recent results',
        Icons.search_off_rounded,
        (scheme) => scheme.tertiary,
      );
    }
    if (health != null && health.pingMs > 2500) {
      return ProviderQualityHint._(
        'Slow',
        Icons.speed_rounded,
        (scheme) => scheme.secondary,
      );
    }
    if (health != null || diagnostics != null) {
      return ProviderQualityHint._(
        'Healthy',
        Icons.check_circle_outline_rounded,
        (scheme) => scheme.primary,
      );
    }
    return ProviderQualityHint._(
      'Not checked',
      Icons.help_outline_rounded,
      (scheme) => scheme.outline,
    );
  }
}
