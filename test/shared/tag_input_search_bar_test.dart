import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/backend.dart';
import 'package:gel_rule_app/shared/widgets/app_search_bar.dart';

void main() {
  testWidgets('commits typed tag with space', (tester) async {
    String? changed;
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
          onSubmitted: (_) {},
          onChanged: (value) {
            changed = value;
          }),
    ));

    await tester.enterText(find.byType(TextField), 'touhou ');
    await tester.pump();
    await tester.pump();

    expect(find.text('touhou'), findsOneWidget);
    expect(changed, 'touhou');
  });

  testWidgets('submits committed tags on search action', (tester) async {
    String? submitted;
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(onSubmitted: (value) {
        submitted = value;
      }),
    ));

    await tester.enterText(find.byType(TextField), 'touhou ');
    await tester.pump();
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submitted, 'touhou');
  });

  testWidgets('deleting chip updates query', (tester) async {
    String? changed;
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'touhou video',
        onSubmitted: (_) {},
        onChanged: (value) {
          changed = value;
        },
      ),
    ));

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();

    expect(changed, 'video');
  });

  testWidgets('suggestion appends active tag as a chip', (tester) async {
    String? applied;
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        suggestions: const [
          TagSuggestion(
            name: 'touhou',
            category: TagCategory.copyright,
            postCount: 1200,
            providerId: 'danbooru',
          ),
        ],
        onSubmitted: (_) {},
        onSuggestionApplied: (value) {
          applied = value;
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'tou');
    await tester.pump();
    await tester.tap(find.text('touhou'));
    await tester.pump();

    expect(find.text('touhou'), findsWidgets);
    expect(applied, 'touhou');
  });

  testWidgets('many chips stay in a single compact row', (tester) async {
    await tester.pumpWidget(_Harness(
      child: SizedBox(
        width: 320,
        child: TagInputSearchBar(
          initialValue:
              'touhou video hakurei_reimu kirisame_marisa kochiya_sanae cirno',
          onSubmitted: (_) {},
        ),
      ),
    ));

    final size = tester.getSize(find.byType(TagInputSearchBar));

    expect(size.height, lessThan(96));
    expect(find.text('touhou'), findsOneWidget);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
