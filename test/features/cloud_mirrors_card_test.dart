import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/app/app_strings.dart';
import 'package:gel_rule_app/backend/models/cloud_media_link.dart';
import 'package:gel_rule_app/features/post/presentation/widgets/cloud_mirrors_card.dart';

void main() {
  testWidgets('CloudMirrorsCard renders mirrors, password banner, and commentary', (tester) async {
    const links = [
      CloudMediaLink(
        url: 'https://mega.nz/file/xyz123#abc',
        service: CloudServiceType.mega,
        title: 'MEGA 4K Archive',
        isFolder: false,
        isStreamable: false,
        detectedPassword: 'archive_pass_42',
      ),
      CloudMediaLink(
        url: 'https://drive.google.com/file/d/123/view',
        service: CloudServiceType.googleDrive,
        title: 'Google Drive Stream',
        directStreamUrl: 'https://drive.google.com/uc?export=download&id=123',
        isFolder: false,
        isStreamable: true,
      ),
    ];

    var playedStream = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CloudMirrorsCard(
              links: links,
              strings: const AppStrings('ru'),
              commentary: 'Special Patreon bonus animation for all patrons.',
              onPlayStream: (stream) => playedStream = stream,
              initiallyExpanded: true,
            ),
          ),
        ),
      ),
    );

    // Verify header and counts
    expect(find.text('Облачные диски и зеркала (2)'), findsOneWidget);
    expect(find.text('Плеер'), findsOneWidget);

    // Verify password banner
    expect(find.textContaining('archive_pass_42'), findsOneWidget);

    // Verify link titles and service names
    expect(find.text('MEGA'), findsOneWidget);
    expect(find.text('MEGA 4K Archive'), findsOneWidget);
    expect(find.text('Google Drive'), findsOneWidget);
    expect(find.text('Google Drive Stream'), findsOneWidget);

    // Verify play button triggers callback on mirrors tab
    final playBtn = find.text('Смотреть');
    expect(playBtn, findsOneWidget);
    await tester.tap(playBtn);
    expect(playedStream, 'https://drive.google.com/uc?export=download&id=123');

    // Switch to description tab and verify commentary
    final descTab = find.text('Описание');
    expect(descTab, findsOneWidget);
    await tester.tap(descTab);
    await tester.pumpAndSettle();

    // Verify commentary
    expect(find.text('Описание от автора'), findsOneWidget);
    expect(find.text('Special Patreon bonus animation for all patrons.'), findsOneWidget);
  });

  testWidgets('CloudMirrorsCard renders nothing if no links and no commentary', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CloudMirrorsCard(
            links: [],
            strings: AppStrings('ru'),
          ),
        ),
      ),
    );

    expect(find.byType(Container), findsNothing);
  });
}
