import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../backend/backend.dart';
import '../../../../shared/widgets/provider_status_badge.dart';

class ProviderHealthTile extends StatefulWidget {
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
  State<ProviderHealthTile> createState() => _ProviderHealthTileState();
}

class _ProviderHealthTileState extends State<ProviderHealthTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';
    final config = widget.config;
    final health = widget.health;
    final diagnostics = widget.diagnostics;

    final hint = ProviderQualityHint.from(
      config: config,
      health: health,
      diagnostics: diagnostics,
      isRu: isRu,
    );

    final status = health?.status ?? ProviderStatus.unknown;
    final statusColor = switch (status) {
      ProviderStatus.online => (health != null && health.pingMs > 2500)
          ? const Color(0xFFF59E0B)
          : const Color(0xFF10B981),
      ProviderStatus.offline => const Color(0xFFEF4444),
      ProviderStatus.unknown => const Color(0xFF94A3B8),
    };

    final hasError = diagnostics?.lastErrorMessage != null ||
        health?.errorMessage != null;
    final errorMessage = diagnostics?.lastErrorMessage ?? health?.errorMessage;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.30)
                : statusColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.06 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      theme.colorScheme.surfaceContainerHigh
                          .withValues(alpha: 0.65),
                      theme.colorScheme.surfaceContainerLow
                          .withValues(alpha: 0.40),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.92),
                      Colors.white.withValues(alpha: 0.78),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? statusColor.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.90),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Tile
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _expanded = !_expanded);
                },
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Status Badge with glowing LED
                      ProviderStatusBadge(health: health),
                      const SizedBox(width: 12),

                      // Name & Badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              config.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Ping chip if available
                                if (health != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                          alpha: isDark ? 0.16 : 0.10),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: statusColor.withValues(
                                            alpha: isDark ? 0.38 : 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.bolt_rounded,
                                          size: 12,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${health.pingMs} ms',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Quality Hint Chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: hint.color(context).withValues(
                                        alpha: isDark ? 0.14 : 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: hint.color(context).withValues(
                                          alpha: isDark ? 0.32 : 0.20),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        hint.icon,
                                        size: 12,
                                        color: hint.color(context),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hint.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: hint.color(context),
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Check Button
                      IconButton(
                        tooltip: isRu ? 'Проверить' : 'Check',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onCheck();
                        },
                        icon: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: isDark ? 0.18 : 0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: isDark ? 0.40 : 0.25),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),

                      // Expand Chevron
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Diagnostics Section
              if (_expanded) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Diagnostic row 1: URL & Enabled
                      _DiagItem(
                        icon: Icons.link_rounded,
                        label: isRu ? 'Сервер' : 'Endpoint',
                        value: '${config.baseUrl} (${config.enabled ? (isRu ? 'Активен' : 'Enabled') : (isRu ? 'Выключен' : 'Disabled')})',
                        isMonospace: true,
                      ),
                      const SizedBox(height: 8),

                      // Diagnostic row 2: API Type & Priority
                      _DiagItem(
                        icon: Icons.hub_outlined,
                        label: isRu ? 'Движок и приоритет' : 'Engine & Priority',
                        value: '${config.apiType} · ${isRu ? 'приоритет' : 'priority'} ${config.priority}',
                      ),
                      const SizedBox(height: 8),

                      // Diagnostic row 3: API Version
                      if (health?.apiVersion != null) ...[
                        _DiagItem(
                          icon: Icons.info_outline_rounded,
                          label: isRu ? 'Версия API' : 'API Version',
                          value: health!.apiVersion!,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Diagnostic row 4: Last Checked Time
                      if (health?.lastCheckedAt != null) ...[
                        _DiagItem(
                          icon: Icons.schedule_rounded,
                          label: isRu ? 'Проверено' : 'Last Checked',
                          value: health!.lastCheckedAt.toString().split('.').first,
                          isMonospace: true,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Diagnostic row 5: Last Search
                      if (diagnostics != null) ...[
                        _DiagItem(
                          icon: Icons.search_rounded,
                          label: isRu ? 'Последний поиск' : 'Last Search',
                          value: isRu
                              ? '${diagnostics.lastResultCount} постов получено в ${diagnostics.lastSearchAt.toString().split('.').first}'
                              : '${diagnostics.lastResultCount} posts retrieved at ${diagnostics.lastSearchAt.toString().split('.').first}',
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Error Box (if any)
                      if (hasError && errorMessage != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: isDark ? 0.16 : 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: isDark ? 0.38 : 0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Color(0xFFEF4444),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagItem extends StatelessWidget {
  const _DiagItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontFamily: isMonospace ? 'monospace' : null,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
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
    required bool isRu,
  }) {
    if (!config.enabled) {
      return ProviderQualityHint._(
        isRu ? 'Выключен' : 'Disabled',
        Icons.pause_circle_outline_rounded,
        (scheme) => scheme.outline,
      );
    }
    if (diagnostics?.lastErrorMessage != null ||
        health?.status == ProviderStatus.offline) {
      return ProviderQualityHint._(
        isRu ? 'Ошибка поиска' : 'Search failing',
        Icons.error_outline_rounded,
        (scheme) => scheme.error,
      );
    }
    if (diagnostics != null && diagnostics.lastResultCount == 0) {
      return ProviderQualityHint._(
        isRu ? 'Нет результатов' : 'No recent results',
        Icons.search_off_rounded,
        (scheme) => scheme.tertiary,
      );
    }
    if (health != null && health.pingMs > 2500) {
      return ProviderQualityHint._(
        isRu ? 'Медленно' : 'Slow',
        Icons.speed_rounded,
        (scheme) => scheme.secondary,
      );
    }
    if (health != null || diagnostics != null) {
      return ProviderQualityHint._(
        isRu ? 'Стабилен' : 'Healthy',
        Icons.check_circle_outline_rounded,
        (scheme) => scheme.primary,
      );
    }
    return ProviderQualityHint._(
      isRu ? 'Не проверен' : 'Not checked',
      Icons.help_outline_rounded,
      (scheme) => scheme.outline,
    );
  }
}
