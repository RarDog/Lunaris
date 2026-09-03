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

  testWidgets('clear button removes all committed tags', (tester) async {
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

    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();

    expect(find.text('touhou'), findsNothing);
    expect(find.text('video'), findsNothing);
    expect(changed, '');
  });

  testWidgets('external initial value replaces committed tags', (tester) async {
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'old_tag',
        onSubmitted: (_) {},
      ),
    ));

    expect(find.text('old_tag'), findsOneWidget);

    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'new_tag',
        onSubmitted: (_) {},
      ),
    ));
    await tester.pump();

    expect(find.text('old_tag'), findsNothing);
    expect(find.text('new_tag'), findsOneWidget);
  });

  testWidgets('old external value does not restore deleted chip',
      (tester) async {
    String? changed;
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'old_tag keep_tag',
        onSubmitted: (_) {},
        onChanged: (value) {
          changed = value;
        },
      ),
    ));

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'old_tag keep_tag',
        onSubmitted: (_) {},
        onChanged: (value) {
          changed = value;
        },
      ),
    ));
    await tester.pump();

    expect(find.text('old_tag'), findsNothing);
    expect(find.text('keep_tag'), findsOneWidget);
    expect(changed, 'keep_tag');
  });

  testWidgets('focused draft is not replaced by stale external value',
      (tester) async {
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'old_tag',
        onSubmitted: (_) {},
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'new_tag');
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'old_tag',
        onSubmitted: (_) {},
      ),
    ));
    await tester.pump();

    expect(find.text('old_tag'), findsOneWidget);
    expect(find.text('new_tag'), findsOneWidget);
  });

  testWidgets('matching external draft does not become a chip while focused',
      (tester) async {
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: '',
        onSubmitted: (_) {},
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'draft_tag');
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'draft_tag',
        onSubmitted: (_) {},
      ),
    ));
    await tester.pump();

    expect(find.byType(InputChip), findsNothing);
    expect(find.text('draft_tag'), findsOneWidget);
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

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'tou');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('touhou'));
    await tester.pump();

    expect(find.text('touhou'), findsWidgets);
    expect(applied, 'touhou');
  });

  testWidgets('stale suggestions are hidden for a newer active token',
      (tester) async {
    await tester.pumpWidget(_Harness(
      child: SizedBox(
        width: 360,
        child: TagInputSearchBar(
          suggestions: const [
            TagSuggestion(
              name: 'touhou',
              category: TagCategory.copyright,
              postCount: 1200,
              providerId: 'gelbooru',
            ),
          ],
          onSubmitted: (_) {},
        ),
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'tou');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('touhou'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cat');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('touhou'), findsNothing);
  });

  testWidgets('suggestions overlay does not resize search bar', (tester) async {
    await tester.pumpWidget(_Harness(
      child: SizedBox(
        width: 360,
        child: TagInputSearchBar(
          suggestions: const [
            TagSuggestion(
              name: 'touhou',
              category: TagCategory.copyright,
              postCount: 1200,
              providerId: 'gelbooru',
            ),
            TagSuggestion(
              name: 'tou_tail',
              category: TagCategory.general,
              postCount: 900,
              providerId: 'e621',
            ),
          ],
          onSubmitted: (_) {},
        ),
      ),
    ));

    final initialHeight = tester.getSize(find.byType(TagInputSearchBar)).height;
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'tou');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('touhou'), findsOneWidget);
    expect(find.text('tou_tail'), findsOneWidget);
    expect(
        tester.getSize(find.byType(TagInputSearchBar)).height, initialHeight);
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
