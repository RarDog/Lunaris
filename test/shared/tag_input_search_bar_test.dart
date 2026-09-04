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

  testWidgets('preserves AND operator chips when submitted', (tester) async {
    String submitted = '';
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'cat and dog',
        onSubmitted: (query) => submitted = query,
      ),
    ));

    expect(find.text('cat'), findsOneWidget);
    expect(find.text('AND'), findsOneWidget);
    expect(find.text('dog'), findsOneWidget);

    await tester.showKeyboard(find.byType(TextField));
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(submitted, 'cat and dog');
  });

  testWidgets('applying suggestion preserves preceding tokens and AND operator',
      (tester) async {
    String applied = '';
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        suggestions: const [
          TagSuggestion(
            name: 'dog',
            category: TagCategory.general,
            postCount: 50,
            providerId: 'test',
          ),
        ],
        onSuggestionApplied: (query) => applied = query,
        onSubmitted: (_) {},
      ),
    ));

    await tester.enterText(find.byType(TextField), 'cat and d');
    await tester.pumpAndSettle();

    expect(find.text('dog'), findsOneWidget);
    await tester.tap(find.text('dog'));
    await tester.pumpAndSettle();

    expect(applied, 'cat and dog');
    expect(find.text('cat'), findsOneWidget);
    expect(find.text('AND'), findsOneWidget);
    expect(find.text('dog'), findsOneWidget);
  });

  testWidgets('deleting chip triggers onTagRemoved', (tester) async {
    String? removedQuery;
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'cat dog',
        onSubmitted: (_) {},
        onTagRemoved: (query) => removedQuery = query,
      ),
    ));

    expect(find.text('cat'), findsOneWidget);
    expect(find.text('dog'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();

    expect(removedQuery, 'dog');
    expect(find.text('cat'), findsNothing);
    expect(find.text('dog'), findsOneWidget);
  });

  testWidgets('clear button triggers onCleared and onSubmitted with empty string',
      (tester) async {
    bool cleared = false;
    String? submitted;
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        initialValue: 'cat dog',
        onSubmitted: (query) => submitted = query,
        onCleared: () => cleared = true,
      ),
    ));

    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();

    expect(cleared, isTrue);
    expect(submitted, '');
    expect(find.text('cat'), findsNothing);
    expect(find.text('dog'), findsNothing);
  });

  testWidgets(
      'tapping external button while suggestions are visible triggers button and hides suggestions',
      (tester) async {
    bool externalButtonPressed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TagInputSearchBar(
                  suggestions: const [
                    TagSuggestion(
                      name: 'genshin',
                      category: TagCategory.copyright,
                      postCount: 100,
                      providerId: 'test',
                    ),
                  ],
                  onSubmitted: (_) {},
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => externalButtonPressed = true,
                child: const Text('Обновить'),
              ),
            ],
          ),
        ),
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'gen');
    await tester.pumpAndSettle();

    expect(find.text('genshin'), findsOneWidget);

    // Tap external 'Обновить' button directly while suggestions are up
    await tester.tap(find.text('Обновить'));
    await tester.pumpAndSettle();

    expect(externalButtonPressed, isTrue);
    expect(find.text('genshin'), findsNothing);
  });

  testWidgets('erasing draft immediately hides suggestions', (tester) async {
    await tester.pumpWidget(_Harness(
      child: TagInputSearchBar(
        suggestions: const [
          TagSuggestion(
            name: 'genshin',
            category: TagCategory.copyright,
            postCount: 100,
            providerId: 'test',
          ),
        ],
        onSubmitted: (_) {},
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'gen');
    await tester.pumpAndSettle();

    expect(find.text('genshin'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('genshin'), findsNothing);
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
