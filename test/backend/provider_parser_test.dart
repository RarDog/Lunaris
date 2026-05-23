import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/mappers/danbooru_mapper.dart';
import 'package:gel_rule_app/backend/mappers/gelbooru_mapper.dart';
import 'package:gel_rule_app/backend/mappers/rule34_mapper.dart';

void main() {
  test('parses Gelbooru array response', () {
    final posts = GelbooruMapper.postsFromResponse(
      [
        {
          'id': 1,
          'file_url': 'https://example.test/a.jpg',
          'sample_url': 'https://example.test/sample.jpg',
          'preview_url': 'https://example.test/preview.jpg',
          'tags': 'cat cute',
          'rating': 'safe',
          'width': '100',
          'height': '200',
          'score': '7',
        }
      ],
      providerId: 'gelbooru',
      providerName: 'Gelbooru',
    );

    expect(posts, hasLength(1));
    expect(posts.first.id, '1');
    expect(posts.first.tags, ['cat', 'cute']);
    expect(posts.first.fileType, 'image');
  });

  test('parses Gelbooru object/posts response', () {
    final posts = GelbooruMapper.postsFromResponse(
      {
        'post': [
          {'id': '2', 'file_url': 'https://example.test/b.gif'}
        ],
      },
      providerId: 'gelbooru',
      providerName: 'Gelbooru',
    );

    expect(posts.single.id, '2');
    expect(posts.single.fileType, 'gif');
  });

  test('parses Rule34 compatible response', () {
    final posts = Rule34Mapper.postsFromResponse(
      {
        'posts': [
          {'id': '3', 'file_url': 'https://example.test/c.webm'}
        ],
      },
      providerId: 'rule34',
      providerName: 'Rule34',
    );

    expect(posts.single.providerId, 'rule34');
    expect(posts.single.fileType, 'video');
  });

  test('parses Danbooru response', () {
    final posts = DanbooruMapper.postsFromResponse(
      [
        {
          'id': 4,
          'file_url': 'https://example.test/d.png',
          'large_file_url': 'https://example.test/large.png',
          'preview_file_url': 'https://example.test/preview.png',
          'tag_string': 'blue sky',
          'image_width': 640,
          'image_height': 480,
        }
      ],
      providerId: 'danbooru',
      providerName: 'Danbooru',
    );

    expect(posts.single.id, '4');
    expect(posts.single.previewUrl, contains('preview'));
    expect(posts.single.tags, ['blue', 'sky']);
  });

  test('missing optional fields do not crash parser', () {
    final posts = GelbooruMapper.postsFromResponse(
      [
        {'id': 5}
      ],
      providerId: 'gelbooru',
      providerName: 'Gelbooru',
    );

    expect(posts.single.fileUrl, '');
    expect(posts.single.rating, 'unknown');
  });
}
