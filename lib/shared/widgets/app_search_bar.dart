import 'dart:async';

import 'package:flutter/material.dart';

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

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialValue ?? '';
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != next) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
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
            _controller.clear();
            widget.onChanged?.call('');
          },
        ),
      ),
    );
  }
}
