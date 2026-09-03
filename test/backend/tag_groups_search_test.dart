import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/providers/provider_manager.dart';

void main() {
  group('Tag groups splitting: space groups together, and separates streams', () {
    test('single tag returns one group', () {
      final groups = ProviderManager.splitTagGroups(['cat']);
      expect(groups, equals([['cat']]));
    });

    test('tags separated by space are grouped together in one query', () {
      final groups = ProviderManager.splitTagGroups(['raiden', 'miku']);
      expect(groups, equals([
        ['raiden', 'miku'],
      ]));
    });

    test('tags separated by and are split into independent query streams', () {
      final groups = ProviderManager.splitTagGroups(['raiden', 'and', 'miku']);
      expect(groups, equals([
        ['raiden'],
        ['miku'],
      ]));
    });

    test('multiple multi-tag groups separated by and', () {
      final groups = ProviderManager.splitTagGroups([
        'genshin',
        'raiden',
        'and',
        'vocaloid',
        'miku',
      ]);
      expect(groups, equals([
        ['genshin', 'raiden'],
        ['vocaloid', 'miku'],
      ]));
    });

    test('case-insensitive AND separator', () {
      final groups = ProviderManager.splitTagGroups(['cat', 'AND', 'dog']);
      expect(groups, equals([
        ['cat'],
        ['dog'],
      ]));
    });

    test('empty tags return empty group list', () {
      final groups = ProviderManager.splitTagGroups([]);
      expect(groups, equals([const <String>[]]));
    });
  });
}
