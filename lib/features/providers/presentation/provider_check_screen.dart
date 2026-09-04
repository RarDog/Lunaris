import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/error_view.dart';
import 'providers_controller.dart';
import 'widgets/provider_health_tile.dart';

class ProviderCheckScreen extends ConsumerStatefulWidget {
  const ProviderCheckScreen({super.key});

  @override
  ConsumerState<ProviderCheckScreen> createState() =>
      _ProviderCheckScreenState();
}

class _ProviderCheckScreenState extends ConsumerState<ProviderCheckScreen> {
  bool _isCheckingAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';
    final providers = ref.watch(providersControllerProvider);
    final health = ref.watch(providerHealthProvider);
    final diagnostics = ref.watch(providerDiagnosticsProvider).value ?? {};
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AppBar(
              backgroundColor: isDark
                  ? theme.colorScheme.surface.withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.85),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/providers');
                  }
                },
                tooltip: isRu ? 'Назад' : 'Back',
              ),
              title: Text(
                isRu ? 'Проверка источников' : 'Provider Check',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _isCheckingAll ? null : () => _checkAll(ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isCheckingAll)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(
                                Icons.playlist_add_check_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 5),
                            Text(
                              isRu ? 'Проверить все' : 'Check All',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: providers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (items) {
          int onlineCount = 0;
          int offlineCount = 0;
          int pingSum = 0;
          int pingCount = 0;

          for (final item in items) {
            final h = health[item.id];
            if (h != null) {
              if (h.status == ProviderStatus.online) {
                onlineCount++;
                pingSum += h.pingMs;
                pingCount++;
              } else if (h.status == ProviderStatus.offline) {
                offlineCount++;
              }
            }
          }

          final avgPing =
              pingCount > 0 ? (pingSum / pingCount).round() : null;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.paddingOf(context).top + 68,
                  16,
                  140 + bottomInset,
                ),
                children: [
                  // Status Overview Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
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
                                Colors.white.withValues(alpha: 0.90),
                                Colors.white.withValues(alpha: 0.75),
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.85),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.25)
                              : const Color(0xFF6366F1).withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Text(
                              isRu ? 'Состояние сети' : 'Network Health',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (avgPing != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(
                                      alpha: isDark ? 0.16 : 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(
                                        alpha: isDark ? 0.38 : 0.25),
                                  ),
                                ),
                                child: Text(
                                  '${isRu ? 'Средний пинг' : 'Avg ping'}: $avgPing ms',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricPill(
                                label: isRu ? 'Всего' : 'Total',
                                value: '${items.length}',
                                color: theme.colorScheme.primary,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricPill(
                                label: isRu ? 'Онлайн' : 'Online',
                                value: '$onlineCount',
                                color: const Color(0xFF10B981),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricPill(
                                label: isRu ? 'Офлайн' : 'Offline',
                                value: '$offlineCount',
                                color: const Color(0xFFEF4444),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Health Tiles List
                  if (items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHigh
                                .withValues(alpha: 0.40)
                            : Colors.white.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          isRu ? 'Нет источников для проверки' : 'No providers to check',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...items.map((item) {
                      return ProviderHealthTile(
                        key: ValueKey(item.id),
                        config: item,
                        health: health[item.id],
                        diagnostics: diagnostics[item.id],
                        onCheck: () => _checkOne(ref, item.id),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _checkAll(WidgetRef ref) async {
    setState(() => _isCheckingAll = true);
    HapticFeedback.mediumImpact();
    try {
      final result =
          await ref.read(providerCheckServiceProvider).checkAll();
      if (result is Success<List<ProviderHealth>>) {
        ref.read(providerHealthProvider.notifier).state = {
          for (final item in result.data) item.providerId: item,
        };
      }
    } finally {
      if (mounted) setState(() => _isCheckingAll = false);
    }
  }

  Future<void> _checkOne(WidgetRef ref, String providerId) async {
    final result =
        await ref.read(providerCheckServiceProvider).checkOne(providerId);
    if (result is Success<ProviderHealth>) {
      ref.read(providerHealthProvider.notifier).state = {
        ...ref.read(providerHealthProvider),
        providerId: result.data,
      };
    }
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.30 : 0.20),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
