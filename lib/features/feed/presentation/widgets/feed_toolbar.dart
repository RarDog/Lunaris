import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../../../app/responsive.dart';
import '../../../../backend/backend.dart';
import '../../../../shared/widgets/app_search_bar.dart';

class FeedToolbar extends StatefulWidget {
  const FeedToolbar({
    required this.onSearch,
    required this.onRefresh,
    required this.onProviderFilter,
    required this.onRatingFilter,
    required this.onClearFilters,
    required this.providers,
    required this.selectedTags,
    required this.selectedProviderIds,
    required this.topPeriodFilter,
    required this.tagSuggestions,
    required this.rating,
    required this.onQuickProviderToggle,
    required this.onSearchChanged,
    required this.onSuggestionTap,
    required this.onTopPeriodChanged,
    this.onToggleSelectionMode,
    this.onRandom,
    this.providerStatusMessage,
    this.selectionMode = false,
    super.key,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;
  final VoidCallback onProviderFilter;
  final VoidCallback onRatingFilter;
  final VoidCallback onClearFilters;
  final List<ContentProviderConfig> providers;
  final List<String> selectedTags;
  final List<String> selectedProviderIds;
  final TopPeriodFilter topPeriodFilter;
  final List<TagSuggestion> tagSuggestions;
  final String? rating;
  final ValueChanged<String> onQuickProviderToggle;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSuggestionTap;
  final ValueChanged<TopPeriodFilter> onTopPeriodChanged;
  final VoidCallback? onToggleSelectionMode;
  final VoidCallback? onRandom;
  final String? providerStatusMessage;
  final bool selectionMode;

  @override
  State<FeedToolbar> createState() => _FeedToolbarState();
}

class _FeedToolbarState extends State<FeedToolbar> {
  late String _query;

  @override
  void initState() {
    super.initState();
    _query = widget.selectedTags.join(' ');
  }

  @override
  void didUpdateWidget(covariant FeedToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTags != widget.selectedTags) {
      _query = widget.selectedTags.join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) return _buildMobile(context);
    return _buildDesktop(context);
  }

  Widget _buildDesktop(BuildContext context) {
    final hasActiveFilters = widget.selectedProviderIds.isNotEmpty || widget.rating != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TagInputSearchBar(
                  initialValue: _query,
                  suggestions: widget.tagSuggestions,
                  onChanged: (value) {
                    _query = value;
                    widget.onSearchChanged(value);
                  },
                  onSubmitted: widget.onSearch,
                  onSuggestionApplied: (value) {
                    _query = value;
                    widget.onSuggestionTap(value);
                  },
                  onTagRemoved: (value) {
                    _query = value;
                    widget.onSearch(value);
                  },
                  onCleared: () {
                    _query = '';
                    widget.onSearch('');
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: widget.selectionMode ? 'Выйти из выбора (Esc)' : 'Выбрать посты (V)',
                onPressed: widget.onToggleSelectionMode,
                icon: Icon(widget.selectionMode
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded),
              ),
              const SizedBox(width: 4),
              Badge(
                isLabelVisible: hasActiveFilters,
                child: IconButton.filledTonal(
                  tooltip: 'Провайдеры',
                  onPressed: widget.onProviderFilter,
                  icon: const Icon(Icons.hub_rounded),
                ),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                tooltip: 'Рейтинг',
                onPressed: widget.onRatingFilter,
                icon: const Icon(Icons.tune_rounded),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Очистить фильтры',
                onPressed: widget.onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Обновить (Ctrl+R / F5)',
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                tooltip: 'Случайный пост (R)',
                onPressed: widget.onRandom,
                icon: const Icon(Icons.casino_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.providerStatusMessage != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: const Icon(Icons.sync_problem_rounded, size: 16),
                label: Text(widget.providerStatusMessage!),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _HorizontalWheelScroller(
            height: 38,
            builder: (controller) => ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              primary: false,
              children: [
                _LiquidPeriodTabs(
                  selectedPeriod: widget.topPeriodFilter,
                  onChanged: widget.onTopPeriodChanged,
                ),
                const SizedBox(width: 8),
                const _ToolbarDivider(),
                const SizedBox(width: 8),
                if (widget.providers.isNotEmpty) ...[
                  _LiquidProviderPill(
                    label: 'Все источники',
                    isSelected: widget.selectedProviderIds.isEmpty,
                    icon: Icons.all_inclusive_rounded,
                    onTap: () => widget.onQuickProviderToggle('__all__'),
                  ),
                  const SizedBox(width: 6),
                  for (final provider in widget.providers) ...[
                    _LiquidProviderPill(
                      label: provider.name,
                      isSelected: widget.selectedProviderIds.contains(provider.id),
                      icon: Icons.hub_rounded,
                      onTap: () => widget.onQuickProviderToggle(provider.id),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final hasActiveFilters = widget.selectedProviderIds.isNotEmpty || widget.rating != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TagInputSearchBar(
                  initialValue: _query,
                  suggestions: widget.tagSuggestions,
                  onChanged: (value) {
                    _query = value;
                    widget.onSearchChanged(value);
                  },
                  onSubmitted: widget.onSearch,
                  onSuggestionApplied: (value) {
                    _query = value;
                    widget.onSuggestionTap(value);
                  },
                  onTagRemoved: (value) {
                    _query = value;
                    widget.onSearch(value);
                  },
                  onCleared: () {
                    _query = '';
                    widget.onSearch('');
                  },
                ),
              ),
              const SizedBox(width: 6),
              Badge(
                isLabelVisible: hasActiveFilters,
                child: IconButton.filledTonal(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Фильтры',
                  onPressed: widget.onProviderFilter,
                  icon: const Icon(Icons.tune_rounded, size: 20),
                ),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                tooltip: 'Случайный пост',
                onPressed: widget.onRandom,
                icon: const Icon(Icons.casino_rounded, size: 20),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                tooltip: widget.selectionMode ? 'Выйти из выбора' : 'Выбрать посты',
                onPressed: widget.onToggleSelectionMode,
                icon: Icon(
                  widget.selectionMode
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
          if (widget.providerStatusMessage != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: const Icon(Icons.sync_problem_rounded, size: 16),
                label: Text(widget.providerStatusMessage!),
              ),
            ),
          ],
          const SizedBox(height: 7),
          _HorizontalWheelScroller(
            height: 38,
            builder: (controller) => ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              primary: false,
              children: [
                if (hasActiveFilters || widget.selectedTags.isNotEmpty) ...[
                  _LiquidProviderPill(
                    label: 'Сбросить',
                    isSelected: false,
                    icon: Icons.filter_alt_off_rounded,
                    onTap: widget.onClearFilters,
                  ),
                  const SizedBox(width: 6),
                ],
                _LiquidProviderPill(
                  label: 'Обновить',
                  isSelected: false,
                  icon: Icons.refresh_rounded,
                  onTap: widget.onRefresh,
                ),
                const SizedBox(width: 6),
                const _ToolbarDivider(),
                const SizedBox(width: 6),
                _LiquidProviderPill(
                  label: widget.rating ?? 'Рейтинг',
                  isSelected: widget.rating != null,
                  icon: Icons.shield_outlined,
                  onTap: widget.onRatingFilter,
                ),
                const SizedBox(width: 6),
                const _ToolbarDivider(),
                const SizedBox(width: 6),
                _LiquidPeriodTabs(
                  selectedPeriod: widget.topPeriodFilter,
                  onChanged: widget.onTopPeriodChanged,
                ),
                if (widget.providers.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  const _ToolbarDivider(),
                  const SizedBox(width: 6),
                  _LiquidProviderPill(
                    label: 'Все',
                    isSelected: widget.selectedProviderIds.isEmpty,
                    icon: Icons.all_inclusive_rounded,
                    onTap: () => widget.onQuickProviderToggle('__all__'),
                  ),
                  const SizedBox(width: 6),
                  for (final provider in widget.providers) ...[
                    _LiquidProviderPill(
                      label: provider.name,
                      isSelected: widget.selectedProviderIds.contains(provider.id),
                      icon: Icons.hub_rounded,
                      onTap: () => widget.onQuickProviderToggle(provider.id),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }
}

class _LiquidPeriodTabs extends StatelessWidget {
  const _LiquidPeriodTabs({
    required this.selectedPeriod,
    required this.onChanged,
  });

  final TopPeriodFilter selectedPeriod;
  final ValueChanged<TopPeriodFilter> onChanged;

  IconData _iconFor(TopPeriodFilter period) {
    return switch (period) {
      TopPeriodFilter.none => Icons.auto_awesome_rounded,
      TopPeriodFilter.month => Icons.calendar_month_rounded,
      TopPeriodFilter.year => Icons.calendar_today_rounded,
      TopPeriodFilter.allTime => Icons.workspace_premium_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh.withValues(alpha: 0.55)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final period in TopPeriodFilter.values) ...[
            _LiquidPeriodTabItem(
              period: period,
              icon: _iconFor(period),
              isSelected: selectedPeriod == period,
              onTap: () => onChanged(period),
            ),
            if (period != TopPeriodFilter.values.last) const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}

class _LiquidPeriodTabItem extends StatelessWidget {
  const _LiquidPeriodTabItem({
    required this.period,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final TopPeriodFilter period;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? scheme.primary.withValues(alpha: 0.28)
                    : scheme.primaryContainer.withValues(alpha: 0.85))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: isSelected
                ? Border.all(
                    color: scheme.primary.withValues(alpha: isDark ? 0.45 : 0.3),
                    width: 1,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? (isDark ? scheme.primary : scheme.onPrimaryContainer)
                    : scheme.onSurfaceVariant.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                period.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? scheme.primary : scheme.onPrimaryContainer)
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidProviderPill extends StatelessWidget {
  const _LiquidProviderPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? scheme.secondaryContainer.withValues(alpha: 0.35)
                    : scheme.secondaryContainer.withValues(alpha: 0.7))
                : (isDark
                    ? scheme.surfaceContainerHigh.withValues(alpha: 0.4)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? scheme.secondary.withValues(alpha: isDark ? 0.6 : 0.4)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05)),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: scheme.secondary.withValues(alpha: isDark ? 0.2 : 0.08),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? (isDark ? scheme.secondary : scheme.onSecondaryContainer)
                      : scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? scheme.secondary : scheme.onSecondaryContainer)
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalWheelScroller extends StatefulWidget {
  const _HorizontalWheelScroller({
    required this.builder,
    required this.height,
  });

  final Widget Function(ScrollController controller) builder;
  final double height;

  @override
  State<_HorizontalWheelScroller> createState() =>
      _HorizontalWheelScrollerState();
}

class _HorizontalWheelScrollerState extends State<_HorizontalWheelScroller> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Listener(
        onPointerSignal: (event) {
          if (event is! PointerScrollEvent || !_controller.hasClients) return;
          final target = (_controller.offset + event.scrollDelta.dy)
              .clamp(0.0, _controller.position.maxScrollExtent)
              .toDouble();
          _controller.jumpTo(target);
        },
        child: Scrollbar(
          controller: _controller,
          thumbVisibility: false,
          child: widget.builder(_controller),
        ),
      ),
    );
  }
}

Future<List<String>?> showProviderFilterSheet(
  BuildContext context, {
  required List<ContentProviderConfig> providers,
  required List<String> selectedIds,
}) {
  final selected = selectedIds.toSet();
  return showModalBottomSheet<List<String>>(
    context: context,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Providers', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final provider in providers)
            CheckboxListTile(
              value: selected.contains(provider.id),
              title: Text(provider.name),
              subtitle: Text(provider.baseUrl),
              onChanged: (value) {
                setState(() {
                  if (value ?? false) {
                    selected.add(provider.id);
                  } else {
                    selected.remove(provider.id);
                  }
                });
              },
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pop(context, selected.toList()),
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
}

Future<String?> showRatingFilterSheet(BuildContext context, String? selected) {
  return showModalBottomSheet<String?>(
    context: context,
    showDragHandle: true,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Rating', style: Theme.of(context).textTheme.titleLarge),
        ListTile(
          leading: Icon(
            selected == null
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
          ),
          title: const Text('Any'),
          onTap: () => Navigator.pop(context, null),
        ),
        for (final rating in ['safe', 'questionable', 'explicit'])
          ListTile(
            leading: Icon(
              selected == rating
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
            ),
            title: Text(rating),
            onTap: () => Navigator.pop(context, rating),
          ),
      ],
    ),
  );
}
