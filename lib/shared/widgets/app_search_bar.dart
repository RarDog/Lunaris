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
    this.onTagRemoved,
    this.onCleared,
    this.initialValue,
    this.hintText = 'Search tags',
    this.suggestions = const [],
    super.key,
  });

  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSuggestionApplied;
  final ValueChanged<String>? onTagRemoved;
  final VoidCallback? onCleared;
  final String? initialValue;
  final String hintText;
  final List<TagSuggestion> suggestions;

  @override
  State<TagInputSearchBar> createState() => _TagInputSearchBarState();
}

class _TagInputSearchBarState extends State<TagInputSearchBar> {
  final _fieldKey = GlobalKey();
  final _layerLink = LayerLink();
  final _portalController = OverlayPortalController();
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _tagScrollController;
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
    _controller.addListener(_handleControllerChanged);
    _lastExternalValue = widget.initialValue ?? '';
    _setFromQuery(_lastExternalValue);
  }

  void _handleControllerChanged() {
    if (_controller.text.trim().isEmpty && _portalController.isShowing) {
      _portalController.hide();
    }
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
      _syncSuggestions();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    _tagScrollController.dispose();
    _controller.removeListener(_handleControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    if (!_focusNode.hasFocus) {
      if (_portalController.isShowing) {
        _portalController.hide();
      }
      if (!_localDirty) {
        final next = widget.initialValue ?? '';
        if (next != _lastExternalValue) {
          _setFromQuery(next);
          _lastExternalValue = next;
        }
      }
    } else {
      _syncSuggestions();
    }
    setState(() {});
  }

  void _syncSuggestions() {
    if (!mounted) return;
    final token = _activeToken;
    if (!_focusNode.hasFocus || token.isEmpty) {
      if (_portalController.isShowing) {
        _portalController.hide();
      }
      return;
    }
    final matches = _matchingSuggestions;
    if (matches.isEmpty) {
      if (_portalController.isShowing) {
        _portalController.hide();
      }
      return;
    }
    if (!_portalController.isShowing) {
      _portalController.show();
    }
  }

  List<TagSuggestion> get _matchingSuggestions {
    final token = _activeToken;
    if (token.isEmpty) return const [];
    return widget.suggestions
        .where((item) => item.name.toLowerCase().startsWith(token))
        .toList(growable: false);
  }

  void _hideSuggestions() {
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    _focusNode.unfocus();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tagScrollController.hasClients) {
        _tagScrollController.animateTo(
          _tagScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TapRegion(
      groupId: _fieldKey,
      onTapOutside: (_) => _hideSuggestions(),
      child: OverlayPortal(
        controller: _portalController,
        overlayChildBuilder: (context) {
          final token = _activeToken;
          final suggestions = _matchingSuggestions;
          if (suggestions.isEmpty || token.isEmpty) {
            return const SizedBox.shrink();
          }

          final screenSize = MediaQuery.sizeOf(context);
          final renderBox =
              _fieldKey.currentContext?.findRenderObject() as RenderBox?;
          final fieldWidth =
              renderBox?.hasSize == true ? renderBox!.size.width : 360.0;
          final fieldHeight =
              renderBox?.hasSize == true ? renderBox!.size.height : 48.0;

          final screenW = screenSize.width;
          // Substantially wider dropdown:
          // Mobile (< 600px): use full screen width minus comfortable 24px margins.
          // Desktop/Tablet (>= 600px): expand to 1.35x field width, up to 780px.
          final dropdownWidth = screenW < 600
              ? (screenW - 24.0).clamp(fieldWidth, 580.0)
              : (fieldWidth * 1.35).clamp(fieldWidth, (screenW - 32.0).clamp(fieldWidth, 780.0));

          // Ensure dropdown stays fully on screen and doesn't get clipped
          double dxOffset = 0.0;
          if (renderBox?.hasSize == true && renderBox?.attached == true) {
            final globalPos = renderBox!.localToGlobal(Offset.zero);
            final globalRight = globalPos.dx + dropdownWidth;
            final maxRight = screenW - 12.0;
            if (globalRight > maxRight) {
              dxOffset = maxRight - globalRight;
            }
            if (globalPos.dx + dxOffset < 12.0) {
              dxOffset = 12.0 - globalPos.dx;
            }
          }

          return CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(dxOffset, fieldHeight + 6),
            child: Align(
              alignment: Alignment.topLeft,
              child: TapRegion(
                groupId: _fieldKey,
                child: SizedBox(
                  width: dropdownWidth,
                  child: _TagSuggestionDropdown(
                    suggestions: suggestions,
                    query: token,
                    onSelected: _applySuggestion,
                  ),
                ),
              ),
            ),
          );
        },
        child: CompositedTransformTarget(
          link: _layerLink,
          child: DecoratedBox(
            key: _fieldKey,
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor ??
                  scheme.surfaceContainerHighest.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? scheme.primary.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _focusNode.requestFocus,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded,
                        color: scheme.onSurfaceVariant),
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
                                      textInputAction:
                                          TextInputAction.search,
                                      onSubmitted: (_) => _submit(),
                                      onChanged: _handleDraftChanged,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: false,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        hintText: _tags.isEmpty
                                            ? widget.hintText
                                            : 'tag',
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
        ),
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    final scheme = Theme.of(context).colorScheme;
    final isAnd = tag.toLowerCase() == 'and';
    return InputChip(
      label: Text(
        isAnd ? 'AND' : tag,
        style: TextStyle(
          color: isAnd
              ? scheme.onSecondaryContainer
              : scheme.onPrimaryContainer,
          fontWeight: isAnd ? FontWeight.w900 : FontWeight.w700,
          letterSpacing: isAnd ? 0.8 : 0,
        ),
      ),
      avatar: Icon(
        isAnd ? Icons.alt_route_rounded : Icons.tag_rounded,
        size: 16,
        color: isAnd ? scheme.secondary : scheme.primary,
      ),
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      onPressed: () => _editTag(tag),
      onDeleted: () => _removeTag(tag),
      backgroundColor: isAnd
          ? scheme.secondaryContainer.withValues(alpha: 0.7)
          : scheme.primaryContainer.withValues(alpha: 0.54),
      side: BorderSide(
        color: isAnd
            ? scheme.secondary.withValues(alpha: 0.4)
            : scheme.primary.withValues(alpha: 0.18),
      ),
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
    if (value.trim().isEmpty) {
      _debounce?.cancel();
      if (_portalController.isShowing) {
        _portalController.hide();
      }
      setState(() {});
      _notifyChanged();
      return;
    }
    final composing = _controller.value.composing;
    if (!composing.isValid && RegExp(r'\s$').hasMatch(value)) {
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
        if (tag.toLowerCase() == 'and' || !_tags.contains(tag)) {
          _tags.add(tag);
        }
      }
      _controller.clear();
    });
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    _scrollToEnd();
    _notifyChanged();
  }

  void _submit() {
    _debounce?.cancel();
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    _commitDraft(_controller.text);
    _lastExternalValue = _query;
    _localDirty = false;
    _focusNode.unfocus();
    widget.onSubmitted(_query);
  }

  void _clear() {
    _debounce?.cancel();
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    _localDirty = false;
    setState(() {
      _tags = [];
      _controller.clear();
    });
    _lastExternalValue = '';
    _notifyChanged();
    _focusNode.unfocus();
    widget.onCleared?.call();
    widget.onSubmitted('');
  }

  void _editTag(String tag) {
    _localDirty = true;
    if (_portalController.isShowing) {
      _portalController.hide();
    }
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
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    setState(() {
      _tags = _tags.where((item) => item != tag).toList(growable: true);
    });
    _lastExternalValue = _query;
    _notifyChanged();
    if (widget.onTagRemoved != null) {
      widget.onTagRemoved!(_query);
    }
  }

  void _applySuggestion(String suggestion) {
    final draft = _controller.text.trim();
    _localDirty = true;
    setState(() {
      if (draft.isNotEmpty) {
        final tokens = _parseTags(draft);
        if (tokens.isNotEmpty) {
          final prefixTokens = tokens.sublist(0, tokens.length - 1);
          for (final token in prefixTokens) {
            if (token.toLowerCase() == 'and' || !_tags.contains(token)) {
              _tags.add(token);
            }
          }
        }
      }
      if (!_tags.contains(suggestion)) {
        _tags.add(suggestion);
      }
      _controller.clear();
    });
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    _lastExternalValue = _query;
    _scrollToEnd();
    _notifyChanged();
    widget.onSuggestionApplied?.call(_query);
    _focusNode.requestFocus();
  }

  void _notifyChangedDebounced() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), _notifyChanged);
  }

  void _notifyChanged() {
    _localDirty = true;
    widget.onChanged?.call(_query);
    _syncSuggestions();
  }

  List<String> _parseTags(String query) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in query.trim().split(RegExp(r'\s+'))) {
      final tag = raw.trim();
      if (tag.isEmpty) continue;
      if (tag.toLowerCase() != 'and' && !seen.add(tag.toLowerCase())) continue;
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
    final raw = draft.split(RegExp(r'\s+')).last;
    return raw.replaceAll(RegExp(r'^[\(\)]+|[\(\)]+$'), '').trim();
  }

  bool get _isEditing => _focusNode.hasFocus || _localDirty;
}

class _TagSuggestionDropdown extends StatelessWidget {
  const _TagSuggestionDropdown({
    required this.suggestions,
    required this.query,
    required this.onSelected,
  });

  final List<TagSuggestion> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
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
                    Icon(
                      Icons.tag_rounded,
                      color: _categoryAccentColor(suggestion.category, scheme),
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildHighlightedText(
                        context,
                        suggestion.name,
                        query,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _TagSuggestionBadge(
                      category: suggestion.category,
                      label: suggestion.categoryLabel,
                    ),
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

  Widget _buildHighlightedText(
    BuildContext context,
    String text,
    String token,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final defaultStyle = theme.textTheme.bodyLarge ?? const TextStyle();

    final cleanToken = token.trim().toLowerCase();
    if (cleanToken.isEmpty) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: defaultStyle,
      );
    }

    final lowerText = text.toLowerCase();
    final matchIndex = lowerText.indexOf(cleanToken);

    if (matchIndex < 0) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: defaultStyle,
      );
    }

    final before = text.substring(0, matchIndex);
    final match = text.substring(matchIndex, matchIndex + cleanToken.length);
    final after = text.substring(matchIndex + cleanToken.length);

    return Text.rich(
      TextSpan(
        style: defaultStyle,
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(
            text: match,
            style: defaultStyle.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _categoryAccentColor(TagCategory category, ColorScheme scheme) {
    return switch (category) {
      TagCategory.artist => const Color(0xFFFF5252),
      TagCategory.character => const Color(0xFF66BB6A),
      TagCategory.copyright => const Color(0xFFBA68C8),
      TagCategory.species => const Color(0xFF4FC3F7),
      TagCategory.meta => const Color(0xFF90A4AE),
      TagCategory.general || TagCategory.unknown => scheme.primary,
    };
  }

  String _compactCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }
}

class _TagSuggestionBadge extends StatelessWidget {
  const _TagSuggestionBadge({
    required this.category,
    required this.label,
  });

  final TagCategory category;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bgColor, fgColor) = _badgeColors(scheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  (Color, Color) _badgeColors(ColorScheme scheme) {
    return switch (category) {
      TagCategory.artist => (
          const Color(0xFFFF5252).withValues(alpha: 0.16),
          const Color(0xFFFF5252),
        ),
      TagCategory.character => (
          const Color(0xFF4CAF50).withValues(alpha: 0.16),
          const Color(0xFF43A047),
        ),
      TagCategory.copyright => (
          const Color(0xFFAB47BC).withValues(alpha: 0.16),
          const Color(0xFFAB47BC),
        ),
      TagCategory.species => (
          const Color(0xFF29B6F6).withValues(alpha: 0.16),
          const Color(0xFF0288D1),
        ),
      TagCategory.meta => (
          const Color(0xFF78909C).withValues(alpha: 0.16),
          const Color(0xFF607D8B),
        ),
      TagCategory.general || TagCategory.unknown => (
          scheme.primaryContainer.withValues(alpha: 0.55),
          scheme.onPrimaryContainer,
        ),
    };
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
