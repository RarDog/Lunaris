import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/features/post/presentation/widgets/post_media_viewer.dart';

void main() {
  testWidgets('video error retry button invokes callback', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VideoErrorOverlay(
            message: 'network failed',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
