import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/downloaded_media.dart';
import 'package:gel_rule_app/backend/services/downloaded_media_service.dart';
import 'package:gel_rule_app/features/post/presentation/widgets/post_action_bar.dart';

void main() {
  group('DownloadedMediaService formatting & utility tests', () {
    test('formatBytes formats B, KB, MB, GB properly', () {
      expect(DownloadedMediaService.formatBytes(500), '500 B');
      expect(DownloadedMediaService.formatBytes(1536), '1.5 KB');
      expect(DownloadedMediaService.formatBytes(2 * 1024 * 1024), '2.0 MB');
      expect(
        DownloadedMediaService.formatBytes(
            (2.5 * 1024 * 1024 * 1024).toInt()),
        '2.50 GB',
      );
    });

    test('getFileSizeSync handles empty or missing path safely', () {
      final media = DownloadedMedia(
        cacheKey: 'danbooru:1',
        providerId: 'danbooru',
        postId: '1',
        savedPath: '/non/existent/path.jpg',
        fileName: 'path.jpg',
        downloadedAt: DateTime(2026, 1, 1),
        status: 'completed',
      );

      expect(DownloadedMediaService.getFileSizeSync(media), 0);
    });
  });

  group('PostActionBar Action Dock 2.0 tests', () {
    testWidgets('renders primary action dock buttons', (tester) async {
      bool favoriteTapped = false;
      bool downloadTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostActionBar(
              isFavorite: false,
              downloaded: false,
              labels: const PostActionLabels(),
              onFavorite: () => favoriteTapped = true,
              onDownload: () => downloadTapped = true,
              onCollection: () {},
              onShare: () {},
              onOpen: () {},
              onOpenSource: () {},
              onCopy: () {},
              onSimilar: () {},
              onHide: () {},
              onDeleteLocalFile: () {},
            ),
          ),
        ),
      );

      // Verify buttons exist
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

      // Tap favorite
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      expect(favoriteTapped, isTrue);

      // Tap download
      await tester.tap(find.byIcon(Icons.download_rounded));
      expect(downloadTapped, isTrue);
    });

    testWidgets('shows downloaded status badge when downloaded is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostActionBar(
              isFavorite: true,
              downloaded: true,
              labels: const PostActionLabels(),
              onFavorite: () {},
              onDownload: () {},
              onCollection: () {},
              onShare: () {},
              onOpen: () {},
              onOpenSource: () {},
              onCopy: () {},
              onSimilar: () {},
              onHide: () {},
              onDeleteLocalFile: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.offline_pin_rounded), findsOneWidget);
    });
  });
}
