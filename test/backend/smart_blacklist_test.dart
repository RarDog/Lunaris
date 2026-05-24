import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/backend.dart';

void main() {
  test('matches simple tag and multi tag AND rules', () {
    final item = post(tags: ['blue_hair', 'smile']);

    expect(SmartBlacklistMatcher.matches(item, 'blue_hair'), isTrue);
    expect(SmartBlacklistMatcher.matches(item, 'blue_hair smile'), isTrue);
    expect(SmartBlacklistMatcher.matches(item, 'blue_hair red_eyes'), isFalse);
  });

  test('matches provider rating type score and tag groups', () {
    final item = post(
      providerId: 'e621',
      rating: 'explicit',
      fileType: 'video',
      score: 42,
      tagGroups: const {
        'artist': ['artist_name'],
        'character': ['char_name'],
      },
    );

    expect(SmartBlacklistMatcher.matches(item, 'provider:e621'), isTrue);
    expect(SmartBlacklistMatcher.matches(item, 'rating:explicit'), isTrue);
    expect(SmartBlacklistMatcher.matches(item, 'type:video'), isTrue);
    expect(SmartBlacklistMatcher.matches(item, 'score:>40'), isTrue);
    expect(SmartBlacklistMatcher.matches(item, 'artist:artist_name'), isTrue);
    expect(SmartBlacklistMatcher.matches(item, 'character:other'), isFalse);
  });

  test('similar tags prefer grouped identity tags', () {
    final item = post(
      tags: ['general_a', 'general_b'],
      tagGroups: const {
        'artist': ['artist_name'],
        'copyright': ['series_name'],
      },
    );

    expect(similarTagsFor(item), ['artist_name', 'series_name']);
  });
}

Post post({
  String providerId = 'gelbooru',
  String rating = 'safe',
  String fileType = 'image',
  int score = 0,
  List<String> tags = const [],
  Map<String, List<String>> tagGroups = const {},
}) {
  return Post(
    id: '1',
    providerId: providerId,
    providerName: providerId,
    previewUrl: '',
    sampleUrl: '',
    fileUrl: '',
    tags: tags,
    tagGroups: tagGroups,
    rating: rating,
    width: 0,
    height: 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    fileType: fileType,
    score: score,
  );
}
