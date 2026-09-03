import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../backend/backend.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    required this.onSubmitted,
    this.onChanged,
    this.initialValue,
    this.hintText = 'Search tags',
    super.key,
  });

  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final String hintText;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class TagInputSearchBar extends StatefulWidget {
  const TagInputSearchBar({
    required this.onSubmitted,
    this.onChanged,
    this.onSuggestionApplied,
    this.initialValue,
    this.hintText = 'Search tags',
    this.suggestions = const [],
    super.key,
  });

  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSuggestionApplied;
  final String? initialValue;
  final String hintText;
  final List<TagSuggestion> suggestions;

  @override
  State<TagInputSearchBar> createState() => _TagInputSearchBarState();
}

class _TagInputSearchBarState extends State<TagInputSearchBar> {
  final _fieldKey = GlobalKey();
  final _layerLink = LayerLink();
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _tagScrollController;
  OverlayEntry? _suggestionsOverlay;
  Timer? _debounce;
  List<String> _tags = [];
  String _lastExternalValue = '';
  bool _localDirty = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _tagScrollController = ScrollController();
    _focusNode.addListener(_handleFocusChanged);
    _lastExternalValue = widget.initialValue ?? '';
    _setFromQuery(_lastExternalValue);
  }

  @override
  void didUpdateWidget(covariant TagInputSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialValue ?? '';
    final externalChanged = next != _lastExternalValue;
    final externalCleared = next.isEmpty && _lastExternalValue.isNotEmpty;
    if (externalChanged && (externalCleared || !_isEditing)) {
      _setFromQuery(next);
      _lastExternalValue = next;
      _localDirty = false;
    }
    if (oldWidget.suggestions != widget.suggestions) {
      _syncSuggestionsOverlay();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeSuggestionsOverlay();
    _tagScrollController.dispose();
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    if (!_focusNode.hasFocus && !_localDirty) {
      final next = widget.initialValue ?? '';
      if (next != _lastExternalValue) {
        _setFromQuery(next);
        _lastExternalValue = next;
      }
    }
    setState(() {});
    _syncSuggestionsOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncSuggestionsOverlay();
    });
    return CompositedTransformTarget(
      link: _layerLink,
      child: DecoratedBox(
        key: _fieldKey,
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor ??
              scheme.surfaceContainerHighest.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focusNode.hasFocus
                ? scheme.primary.withValues(alpha: 0.45)
                : Colors.transparent,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _focusNode.requestFocus,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: Scrollbar(
                      controller: _tagScrollController,
                      thumbVisibility: false,
                      child: SingleChildScrollView(
                        controller: _tagScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final tag in _tags) ...[
                              _buildTagChip(context, tag),
                              const SizedBox(width: 6),
                            ],
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 120,
                                maxWidth: 300,
                              ),
                              child: Focus(
                                onKeyEvent: _handleKeyEvent,
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (_) => _submit(),
                                  onChanged: _handleDraftChanged,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    hintText:
                                        _tags.isEmpty ? widget.hintText : 'tag',
                                    prefixIcon: null,
                                    suffixIcon: null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _clear,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _syncSuggestionsOverlay() {
    final token = _activeToken;
    final suggestions = widget.suggestions
        .where((item) => item.name.toLowerCase().startsWith(token))
        .toList(growable: false);
    if (!_focusNode.hasFocus || token.isEmpty || suggestions.isEmpty) {
      _removeSuggestionsOverlay();
      return;
    }
    final overlay = Overlay.maybeOf(context);
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlay == null || renderBox == null || !renderBox.hasSize) return;

    final size = renderBox.size;
    _removeSuggestionsOverlay();
    _suggestionsOverlay = OverlayEntry(
      builder: (context) => _TagSuggestionOverlay(
        link: _layerLink,
        width: size.width,
        yOffset: size.height + 8,
        suggestions: suggestions,
        onSelected: _applySuggestion,
      ),
    );
    overlay.insert(_suggestionsOverlay!);
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    final scheme = Theme.of(context).colorScheme;
    return InputChip(
      label: Text(tag),
      avatar: const Icon(Icons.tag_rounded, size: 16),
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      onPressed: () => _editTag(tag),
      onDeleted: () => _removeTag(tag),
      backgroundColor: scheme.primaryContainer.withValues(alpha: 0.54),
      labelStyle: TextStyle(
        color: scheme.onPrimaryContainer,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: scheme.primary.withValues(alpha: 0.18)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _commitDraft(_controller.text);
      _submit();
      return KeyEventResult.handled;
    }
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controller.text.isNotEmpty || _tags.isEmpty) {
      return KeyEventResult.ignored;
    }
    final tag = _tags.removeLast();
    _controller.value = TextEditingValue(
      text: tag,
      selection: TextSelection.collapsed(offset: tag.length),
    );
    setState(() {});
    _notifyChanged();
    return KeyEventResult.handled;
  }

  void _handleDraftChanged(String value) {
    _localDirty = true;
    final composing = _controller.value.composing;
    if (!composing.isValid &&
        value.isNotEmpty &&
        RegExp(r'\s$').hasMatch(value)) {
      _commitDraft(value);
      return;
    }
    _notifyChangedDebounced();
  }

  void _setFromQuery(String query) {
    _tags = _parseTags(query);
    _controller.clear();
  }

  void _commitDraft(String value) {
    final additions = _parseTags(value);
    if (additions.isEmpty) return;
    _localDirty = true;
    setState(() {
      for (final tag in additions) {
        if (!_tags.contains(tag)) _tags.add(tag);
      }
      _controller.clear();
    });
    _notifyChanged();
  }

  void _submit() {
    _debounce?.cancel();
    _commitDraft(_controller.text);
    _removeSuggestionsOverlay();
    _lastExternalValue = _query;
    _localDirty = false;
    widget.onSubmitted(_query);
  }

  void _clear() {
    _debounce?.cancel();
    _localDirty = true;
    setState(() {
      _tags = [];
      _controller.clear();
    });
    _notifyChanged();
    _focusNode.requestFocus();
  }

  void _editTag(String tag) {
    _localDirty = true;
    setState(() {
      _tags = _tags.where((item) => item != tag).toList(growable: true);
      _controller.value = TextEditingValue(
        text: tag,
        selection: TextSelection.collapsed(offset: tag.length),
      );
    });
    _notifyChanged();
    _focusNode.requestFocus();
  }

  void _removeTag(String tag) {
    _localDirty = true;
    setState(() {
      _tags = _tags.where((item) => item != tag).toList(growable: true);
    });
    _notifyChanged();
  }

  void _applySuggestion(String suggestion) {
    final draft = _controller.text.trim();
    _localDirty = true;
    setState(() {
      if (draft.isNotEmpty) {
        final draftTags = _parseTags(draft);
        _tags.removeWhere(draftTags.contains);
      }
      if (!_tags.contains(suggestion)) _tags.add(suggestion);
      _controller.clear();
    });
    _notifyChanged();
    _removeSuggestionsOverlay();
    widget.onSuggestionApplied?.call(_query);
    _focusNode.requestFocus();
  }

  void _notifyChangedDebounced() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _notifyChanged);
  }

  void _notifyChanged() {
    _localDirty = true;
    widget.onChanged?.call(_query);
    _syncSuggestionsOverlay();
  }

  List<String> _parseTags(String query) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in query.trim().split(RegExp(r'\s+'))) {
      final tag = raw.trim();
      if (tag.isEmpty || !seen.add(tag)) continue;
      result.add(tag);
    }
    return result;
  }

  String get _query {
    final draft = _controller.text.trim();
    final all = [..._tags, if (draft.isNotEmpty) draft];
    return all.join(' ');
  }

  String get _activeToken {
    final draft = _controller.text.trim().toLowerCase();
    if (draft.isEmpty) return '';
    return draft.split(RegExp(r'\s+')).last;
  }

  bool get _isEditing => _focusNode.hasFocus || _localDirty;
}

class _TagSuggestionOverlay extends StatelessWidget {
  const _TagSuggestionOverlay({
    required this.link,
    required this.width,
    required this.yOffset,
    required this.suggestions,
    required this.onSelected,
  });

  final LayerLink link;
  final double width;
  final double yOffset;
  final List<TagSuggestion> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: Offset(0, yOffset),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width.clamp(280, 620).toDouble(),
            child: _TagSuggestionDropdown(
              suggestions: suggestions,
              onSelected: onSelected,
            ),
          ),
        ),
      ),
    );
  }
}

class _TagSuggestionDropdown extends StatelessWidget {
  const _TagSuggestionDropdown({
    required this.suggestions,
    required this.onSelected,
  });

  final List<TagSuggestion> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: suggestions.length > 8 ? 8 : suggestions.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 52,
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return InkWell(
              onTap: () => onSelected(suggestion.name),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.tag_rounded, color: scheme.primary, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        suggestion.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _TagSuggestionBadge(suggestion.categoryLabel),
                    if (suggestion.postCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        _compactCount(suggestion.postCount),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _compactCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }
}

class _TagSuggestionBadge extends StatelessWidget {
  const _TagSuggestionBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialValue ?? '';
    if (_focusNode.hasFocus) return;
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != next) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        _debounce?.cancel();
        widget.onSubmitted(value);
      },
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 250), () {
          widget.onChanged?.call(value);
        });
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _debounce?.cancel();
            _controller.clear();
            widget.onChanged?.call('');
            _focusNode.requestFocus();
          },
        ),
      ),
    );
  }
}
