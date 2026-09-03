import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/tag_suggestion.dart';
import 'package:gel_rule_app/backend/services/tag_cache_service.dart';

void main() {
  late Directory tempDir;
  late String cacheFilePath;
  late TagCacheService cacheService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lunaris_test_tag_cache');
    cacheFilePath = '${tempDir.path}/test_tags.json';
    cacheService = TagCacheService(customPath: cacheFilePath);
    await cacheService.init();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('TagSuggestion toJson and fromJson work correctly', () {
    const item = TagSuggestion(
      name: 'hatsune_miku',
      category: TagCategory.character,
      postCount: 154200,
      providerId: 'danbooru',
    );
    final json = item.toJson();
    final restored = TagSuggestion.fromJson(json);

    expect(restored.name, 'hatsune_miku');
    expect(restored.category, TagCategory.character);
    expect(restored.postCount, 154200);
    expect(restored.providerId, 'danbooru');
  });

  test('findLocal returns matching tags instantaneously', () async {
    await cacheService.cacheTags([
      const TagSuggestion(
        name: 'cat_ears',
        category: TagCategory.general,
        postCount: 1000,
        providerId: 'gelbooru',
      ),
      const TagSuggestion(
        name: 'caterpillar',
        category: TagCategory.general,
        postCount: 200,
        providerId: 'gelbooru',
      ),
      const TagSuggestion(
        name: 'dog_tail',
        category: TagCategory.general,
        postCount: 800,
        providerId: 'gelbooru',
      ),
    ]);

    final matches = cacheService.findLocal('cat');
    expect(matches.length, 2);
    expect(matches.first.name, 'cat_ears');
    expect(matches[1].name, 'caterpillar');

    final dogMatches = cacheService.findLocal('dog');
    expect(dogMatches.length, 1);
    expect(dogMatches.first.name, 'dog_tail');
  });

  test('findLocal sanitizes parentheses in prefix', () async {
    await cacheService.cacheTags([
      const TagSuggestion(
        name: 'cat_ears',
        category: TagCategory.general,
        postCount: 1000,
        providerId: 'gelbooru',
      ),
    ]);

    final matches = cacheService.findLocal('(cat');
    expect(matches.length, 1);
    expect(matches.first.name, 'cat_ears');
  });

  test('findLocal respects priority tags from search history', () async {
    await cacheService.cacheTags([
      const TagSuggestion(
        name: 'cat_girl',
        category: TagCategory.general,
        postCount: 5000,
        providerId: 'gelbooru',
      ),
      const TagSuggestion(
        name: 'cat_costume',
        category: TagCategory.general,
        postCount: 50,
        providerId: 'gelbooru',
      ),
    ]);

    // Priority tag 'cat_costume' should appear first despite lower postCount
    final matches = cacheService.findLocal(
      'cat',
      priorityTags: ['cat_costume'],
    );
    expect(matches.first.name, 'cat_costume');
    expect(matches[1].name, 'cat_girl');
  });

  test('flush saves tags to file and reloading restores them', () async {
    await cacheService.cacheTags([
      const TagSuggestion(
        name: 'genshin_impact',
        category: TagCategory.copyright,
        postCount: 300000,
        providerId: 'danbooru',
      ),
    ]);
    await cacheService.flush();

    final reloadedService = TagCacheService(customPath: cacheFilePath);
    await reloadedService.init();

    final results = reloadedService.findLocal('genshin');
    expect(results.length, 1);
    expect(results.first.name, 'genshin_impact');
    expect(results.first.category, TagCategory.copyright);
  });

  test('clear removes tags from memory and disk', () async {
    await cacheService.cacheTags([
      const TagSuggestion(
        name: 'raiden_shogun',
        category: TagCategory.character,
        postCount: 45000,
        providerId: 'danbooru',
      ),
    ]);
    await cacheService.flush();
    expect(File(cacheFilePath).existsSync(), isTrue);

    await cacheService.clear();
    expect(cacheService.tagCount, 0);
    expect(File(cacheFilePath).existsSync(), isFalse);
  });
}
