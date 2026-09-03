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
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: widget.selectionMode ? 'Выйти из выбора' : 'Выбрать посты',
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
                tooltip: 'Обновить',
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                tooltip: 'Случайный пост',
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
            height: 36,
            builder: (controller) => ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              primary: false,
              children: [
                if (widget.providers.isNotEmpty) ...[
                  FilterChip(
                    selected: widget.selectedProviderIds.isEmpty,
                    label: const Text('Все источники'),
                    onSelected: (_) => widget.onQuickProviderToggle('__all__'),
                  ),
                  const SizedBox(width: 8),
                  for (final provider in widget.providers) ...[
                    FilterChip(
                      selected:
                          widget.selectedProviderIds.contains(provider.id),
                      avatar: const Icon(Icons.hub_rounded, size: 15),
                      label: Text(provider.name),
                      onSelected: (_) =>
                          widget.onQuickProviderToggle(provider.id),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const SizedBox(width: 4),
                  const _ToolbarDivider(),
                  const SizedBox(width: 10),
                ],
                for (final period in TopPeriodFilter.values) ...[
                  ChoiceChip(
                    selected: widget.topPeriodFilter == period,
                    label: Text(period.label),
                    onSelected: (_) => widget.onTopPeriodChanged(period),
                  ),
                  const SizedBox(width: 8),
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
                  ActionChip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.filter_alt_off_rounded, size: 15),
                    label: const Text('Сбросить'),
                    onPressed: widget.onClearFilters,
                  ),
                  const SizedBox(width: 6),
                ],
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Обновить'),
                  onPressed: widget.onRefresh,
                ),
                const SizedBox(width: 6),
                const _ToolbarDivider(),
                const SizedBox(width: 6),
                FilterChip(
                  visualDensity: VisualDensity.compact,
                  selected: widget.rating != null,
                  avatar: const Icon(Icons.shield_outlined, size: 15),
                  label: Text(widget.rating ?? 'Рейтинг'),
                  onSelected: (_) => widget.onRatingFilter(),
                ),
                const SizedBox(width: 6),
                const _ToolbarDivider(),
                const SizedBox(width: 6),
                if (widget.providers.isNotEmpty) ...[
                  FilterChip(
                    visualDensity: VisualDensity.compact,
                    selected: widget.selectedProviderIds.isEmpty,
                    label: const Text('Все'),
                    onSelected: (_) => widget.onQuickProviderToggle('__all__'),
                  ),
                  const SizedBox(width: 6),
                  for (final provider in widget.providers) ...[
                    FilterChip(
                      visualDensity: VisualDensity.compact,
                      selected:
                          widget.selectedProviderIds.contains(provider.id),
                      label: Text(provider.name),
                      onSelected: (_) =>
                          widget.onQuickProviderToggle(provider.id),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const SizedBox(width: 2),
                  const _ToolbarDivider(),
                  const SizedBox(width: 6),
                ],
                for (final period in TopPeriodFilter.values) ...[
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    selected: widget.topPeriodFilter == period,
                    label: Text(period.label),
                    onSelected: (_) => widget.onTopPeriodChanged(period),
                  ),
                  const SizedBox(width: 6),
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
