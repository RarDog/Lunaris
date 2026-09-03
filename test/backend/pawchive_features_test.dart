import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/artist_announcement.dart';
import 'package:gel_rule_app/backend/models/artist_link.dart';
import 'package:gel_rule_app/backend/models/artist_tag.dart';
import 'package:gel_rule_app/backend/models/artist_work_query.dart';

void main() {
  group('Pawchive API Features Tests', () {
    test('ArtistTag model fromJson and toJson roundtrip', () {
      final json = {
        'tag': 'genshin_impact',
        'post_count': 42,
      };

      final tag = ArtistTag.fromJson(json);
      expect(tag.tag, equals('genshin_impact'));
      expect(tag.postCount, equals(42));
      expect(tag.toJson(), equals(json));
    });

    test('ArtistLink model parses all fields correctly', () {
      final json = {
        'id': '123456',
        'service': 'fanbox',
        'name': 'CoolArtist',
        'public_id': 'cool_pub_id',
        'indexed': '2026-09-03T12:00:00.000Z',
        'updated': '2026-09-03T14:00:00.000Z',
      };

      final link = ArtistLink.fromJson(json);
      expect(link.id, equals('123456'));
      expect(link.service, equals('fanbox'));
      expect(link.name, equals('CoolArtist'));
      expect(link.publicId, equals('cool_pub_id'));
      expect(link.indexed, isNotNull);
      expect(link.updated, isNotNull);
    });

    test('ArtistAnnouncement model parses content and date', () {
      final json = {
        'service': 'patreon',
        'user_id': '778899',
        'content': 'Taking a vacation next week!',
        'added': '2026-08-01T10:00:00.000Z',
        'hash': 'abc123hash',
      };

      final announcement = ArtistAnnouncement.fromJson(json);
      expect(announcement.service, equals('patreon'));
      expect(announcement.userId, equals('778899'));
      expect(announcement.content, contains('vacation'));
      expect(announcement.added, isNotNull);
      expect(announcement.hash, equals('abc123hash'));
    });

    test('ArtistWorkQuery supports queryText and tagFilter', () {
      const query = ArtistWorkQuery(
        providerId: 'pawchive',
        service: 'fanbox',
        artistId: '112233',
        artistName: 'TestArtist',
        queryText: 'mp4',
        tagFilter: 'cyberpunk',
      );

      expect(query.queryText, equals('mp4'));
      expect(query.tagFilter, equals('cyberpunk'));

      final modified = query.copyWith(queryText: 'gif');
      expect(modified.queryText, equals('gif'));
      expect(modified.tagFilter, equals('cyberpunk'));
      expect(modified == query, isFalse);
    });
  });
}
