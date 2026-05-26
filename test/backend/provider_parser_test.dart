import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/mappers/danbooru_mapper.dart';
import 'package:gel_rule_app/backend/mappers/e621_mapper.dart';
import 'package:gel_rule_app/backend/mappers/gelbooru_mapper.dart';
import 'package:gel_rule_app/backend/mappers/moebooru_mapper.dart';
import 'package:gel_rule_app/backend/mappers/rule34_mapper.dart';
import 'package:gel_rule_app/backend/models/content_provider_config.dart';
import 'package:gel_rule_app/backend/providers/danbooru_provider.dart';
import 'package:gel_rule_app/backend/providers/kemono_provider.dart';
import 'package:gel_rule_app/backend/providers/provider_factory.dart';
import 'package:gel_rule_app/backend/providers/realbooru_provider.dart';
import 'package:gel_rule_app/backend/repositories/provider_repository.dart';

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

  test('parses Gelbooru compatible XML post response', () {
    final posts = GelbooruMapper.postsFromResponse(
      '''
      <posts count="1">
        <post id="7" file_url="https://example.test/r.jpg" preview_url="https://example.test/r-preview.jpg" tags="real booru" rating="explicit" width="300" height="400" score="12" />
      </posts>
      ''',
      providerId: 'realbooru',
      providerName: 'Realbooru',
    );

    expect(posts.single.id, '7');
    expect(posts.single.providerId, 'realbooru');
    expect(posts.single.tags, ['real', 'booru']);
    expect(posts.single.rating, 'explicit');
  });

  test('parses Gelbooru compatible tag category fields', () {
    final posts = GelbooruMapper.postsFromResponse(
      [
        {
          'id': '8',
          'file_url': 'https://example.test/cat.jpg',
          'tag_string_artist': 'artist_name',
          'tag_string_character': 'char_name',
          'tag_string_copyright': 'source_title',
          'tag_string_general': 'blue sky',
          'tag_string_meta': 'highres',
        }
      ],
      providerId: 'gelbooru',
      providerName: 'Gelbooru',
    );

    expect(posts.single.tagGroups['artist'], ['artist_name']);
    expect(posts.single.tagGroups['character'], ['char_name']);
    expect(posts.single.tagGroups['copyright'], ['source_title']);
    expect(posts.single.tagGroups['general'], ['blue', 'sky']);
    expect(posts.single.tagGroups['meta'], ['highres']);
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

  test('parses Rule34 gif with query and file_ext', () {
    final posts = Rule34Mapper.postsFromResponse(
      {
        'posts': [
          {
            'id': '33',
            'file_url': 'https://example.test/c.gif?download=1',
            'file_ext': 'gif',
          }
        ],
      },
      providerId: 'rule34',
      providerName: 'Rule34',
    );

    expect(posts.single.fileType, 'gif');
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

  test('parses Danbooru tag groups', () {
    final posts = DanbooruMapper.postsFromResponse(
      [
        {
          'id': 40,
          'file_url': 'https://example.test/d.jpg',
          'tag_string_general': 'blue sky',
          'tag_string_artist': 'artist_name',
          'tag_string_character': 'char_name',
        }
      ],
      providerId: 'danbooru',
      providerName: 'Danbooru',
    );

    expect(posts.single.tagGroups['artist'], ['artist_name']);
    expect(posts.single.tagGroups['character'], ['char_name']);
    expect(posts.single.tagGroups['general'], ['blue', 'sky']);
  });

  test('parses Moebooru response through Danbooru-compatible mapper', () {
    final posts = MoebooruMapper.postsFromResponse(
      [
        {
          'id': 50,
          'file_url': 'https://example.test/moe.png',
          'tag_string': 'konachan_test',
        }
      ],
      providerId: 'konachan',
      providerName: 'Konachan',
    );

    expect(posts.single.providerId, 'konachan');
    expect(posts.single.tags, ['konachan_test']);
  });

  test('parses e621 response and tag groups', () {
    final posts = E621Mapper.postsFromResponse(
      {
        'posts': [
          {
            'id': 60,
            'file': {
              'url': 'https://example.test/e.webm',
              'width': 1280,
              'height': 720,
              'ext': 'webm',
            },
            'preview': {'url': 'https://example.test/e-preview.jpg'},
            'sample': {'url': 'https://example.test/e-sample.jpg'},
            'rating': 'e',
            'score': {'total': 10},
            'tags': {
              'artist': ['artist_e'],
              'species': ['wolf'],
              'general': ['running'],
            },
          }
        ],
      },
      providerId: 'e621',
      providerName: 'e621',
    );

    expect(posts.single.fileType, 'video');
    expect(posts.single.rating, 'explicit');
    expect(posts.single.tagGroups['species'], ['wolf']);
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

  test('seed providers include CosBooru and no Paheal', () {
    final realbooru = ProviderRepository.seedProviders()
        .where((provider) => provider.id == 'realbooru')
        .single;

    expect(realbooru.enabled, isFalse);
    expect(realbooru.apiType, 'realbooru');
    expect(realbooru.baseUrl, 'https://realbooru.com');
    expect(
      ProviderRepository.seedProviders()
          .where((provider) => provider.id == 'paheal'),
      isEmpty,
    );
    final cosbooru = ProviderRepository.seedProviders()
        .where((provider) => provider.id == 'cosbooru')
        .single;
    final xbooru = ProviderRepository.seedProviders()
        .where((provider) => provider.id == 'xbooru')
        .single;
    expect(xbooru.enabled, isTrue);
    expect(xbooru.apiType, 'gelbooru');
    expect(xbooru.baseUrl, 'https://xbooru.com');
    expect(cosbooru.enabled, isTrue);
    expect(cosbooru.apiType, 'danbooru');
    expect(cosbooru.baseUrl, 'https://cos.lycore.co');
    final kemono = ProviderRepository.seedProviders()
        .where((provider) => provider.id == 'kemono')
        .single;
    final coomer = ProviderRepository.seedProviders()
        .where((provider) => provider.id == 'coomer')
        .single;
    expect(kemono.enabled, isTrue);
    expect(kemono.apiType, 'kemono');
    expect(coomer.enabled, isFalse);
    expect(coomer.apiType, 'coomer');
  });

  test('provider factory creates Realbooru provider', () {
    final now = DateTime(2026);
    final provider = ProviderFactory().create(ContentProviderConfig(
      id: 'realbooru',
      name: 'Realbooru',
      baseUrl: 'https://realbooru.com',
      apiType: 'realbooru',
      enabled: true,
      priority: 7,
      timeoutSeconds: 20,
      customHeaders: const {},
      createdAt: now,
      updatedAt: now,
    ));

    expect(provider, isA<RealbooruProvider>());
  });

  test('provider factory creates CosBooru as Danbooru provider', () {
    final now = DateTime(2026);
    final provider = ProviderFactory().create(ContentProviderConfig(
      id: 'cosbooru',
      name: 'CosBooru',
      baseUrl: 'https://cos.lycore.co',
      apiType: 'danbooru',
      enabled: true,
      priority: 8,
      timeoutSeconds: 20,
      customHeaders: const {},
      createdAt: now,
      updatedAt: now,
    ));

    expect(provider, isA<DanbooruProvider>());
  });

  test('provider factory creates Kemono and Coomer artist providers', () {
    final now = DateTime(2026);
    for (final apiType in ['kemono', 'coomer']) {
      final provider = ProviderFactory().create(ContentProviderConfig(
        id: apiType,
        name: apiType,
        baseUrl: 'https://$apiType.su',
        apiType: apiType,
        enabled: true,
        priority: 10,
        timeoutSeconds: 20,
        customHeaders: const {},
        createdAt: now,
        updatedAt: now,
      ));

      expect(provider, isA<KemonoProvider>());
    }
  });
}
