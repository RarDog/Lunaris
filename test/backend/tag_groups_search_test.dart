import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/providers/provider_manager.dart';

void main() {
  group('Tag groups splitting with local and connector', () {
    test('single tag returns one group', () {
      final groups = ProviderManager.splitTagGroups(['cat']);
      expect(groups, equals([['cat']]));
    });

    test('multiple tags without and are split into separate independent groups', () {
      final groups = ProviderManager.splitTagGroups(['cat', 'dog', 'bird']);
      expect(groups, equals([
        ['cat'],
        ['dog'],
        ['bird'],
      ]));
    });

    test('tags connected by and are merged into the same group', () {
      final groups = ProviderManager.splitTagGroups(['cat', 'and', 'dog']);
      expect(groups, equals([
        ['cat', 'dog'],
      ]));
    });

    test('mixed independent tags and and-connected tags', () {
      final groups = ProviderManager.splitTagGroups([
        'genshin',
        'and',
        'raiden',
        'miku',
        'vocaloid',
        'and',
        'hatsune',
      ]);
      expect(groups, equals([
        ['genshin', 'raiden'],
        ['miku'],
        ['vocaloid', 'hatsune'],
      ]));
    });

    test('case-insensitive AND handling', () {
      final groups = ProviderManager.splitTagGroups(['2girls', 'AND', 'yuri']);
      expect(groups, equals([
        ['2girls', 'yuri'],
      ]));
    });

    test('empty tags return empty group list', () {
      final groups = ProviderManager.splitTagGroups([]);
      expect(groups, equals([const <String>[]]));
    });
  });
}
