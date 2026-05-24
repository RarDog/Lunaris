import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/post.dart';
import 'package:gel_rule_app/backend/services/feed_service.dart';
import 'package:gel_rule_app/backend/services/settings_service.dart';

void main() {
  group('feed tag filters', () {
    test('blacklist hides matching posts', () {
      final post = _post(tags: ['solo', 'blocked_tag']);
      final settings = AppSettings.defaults.copyWith(
        blacklistedTags: ['blocked_tag'],
      );

      expect(postPassesTagFilters(post, settings), isFalse);
    });

    test('whitelist allows only matching posts', () {
      final settings = AppSettings.defaults.copyWith(
        whitelistedTags: ['favorite_tag'],
      );

      expect(
        postPassesTagFilters(_post(tags: ['favorite_tag']), settings),
        isTrue,
      );
      expect(
        postPassesTagFilters(_post(tags: ['other_tag']), settings),
        isFalse,
      );
    });

    test('tag groups participate in filtering', () {
      final post = _post(
        tags: ['general'],
        tagGroups: {
          'artist': ['artist_name'],
        },
      );
      final settings = AppSettings.defaults.copyWith(
        blacklistedTags: ['artist_name'],
      );

      expect(postPassesTagFilters(post, settings), isFalse);
    });

    test('requested search tags are all required', () {
      final post = _post(tags: ['touhou', 'hakurei_reimu']);

      expect(postMatchesRequestedTags(post, ['touhou']), isTrue);
      expect(postMatchesRequestedTags(post, ['touhou', 'cirno']), isFalse);
    });
  });
}

Post _post({
  required List<String> tags,
  Map<String, List<String>> tagGroups = const {},
}) {
  return Post(
    id: '1',
    providerId: 'test',
    providerName: 'Test',
    previewUrl: 'https://example.test/preview.jpg',
    sampleUrl: 'https://example.test/sample.jpg',
    fileUrl: 'https://example.test/file.jpg',
    tags: tags,
    rating: 'general',
    width: 100,
    height: 100,
    createdAt: DateTime(2026),
    fileType: 'photo',
    score: 1,
    tagGroups: tagGroups,
  );
}
