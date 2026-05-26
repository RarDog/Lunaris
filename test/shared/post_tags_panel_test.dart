import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/post.dart';
import 'package:gel_rule_app/features/post/presentation/widgets/post_tags_panel.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('post tags panel renders category blocks with wrapping chips',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: PostTagsPanel(
              post: _post(
                tagGroups: {
                  'artist': ['artist_name'],
                  'character': ['hero'],
                  'general': List.generate(30, (index) => 'tag_$index'),
                },
              ),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Artist'), findsOneWidget);
    expect(find.text('Character'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('artist_name'), findsOneWidget);
    expect(find.text('hero'), findsOneWidget);
    expect(find.text('tag_0'), findsOneWidget);
    expect(find.text('+'), findsNothing);
  });
}

Post _post({required Map<String, List<String>> tagGroups}) {
  return Post(
    id: '1',
    providerId: 'test',
    providerName: 'Test',
    previewUrl: 'https://example.test/preview.jpg',
    sampleUrl: 'https://example.test/sample.jpg',
    fileUrl: 'https://example.test/file.jpg',
    tags: const [],
    rating: 'general',
    width: 100,
    height: 100,
    createdAt: DateTime(2026),
    fileType: 'photo',
    score: 1,
    tagGroups: tagGroups,
  );
}
