import 'package:flutter/material.dart';

import '../../app/responsive.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.title,
    required this.body,
    this.titleWidget,
    this.actions = const [],
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final Widget? titleWidget;
  final Widget body;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return Scaffold(
        appBar: AppBar(
          title: titleWidget ?? Text(title),
          actions: actions,
          toolbarHeight: 52,
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        body: SafeArea(top: false, bottom: false, child: body),
        floatingActionButton: floatingActionButton,
      );
    }
    return Scaffold(
      appBar: AppBar(title: titleWidget ?? Text(title), actions: actions),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
