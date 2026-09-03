import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/search_history.dart';
import 'package:gel_rule_app/backend/repositories/search_repository.dart';
import 'package:gel_rule_app/backend/services/search_service.dart';
import 'package:gel_rule_app/core/utils/result.dart';

class FakeSearchRepository implements SearchRepository {
  final items = <SearchHistory>[];

  @override
  Future<Result<void>> clear() async {
    items.clear();
    return const Success(null);
  }

  @override
  Future<Result<List<SearchHistory>>> recent({int? limit}) async {
    final sorted = [...items]
      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return Success((limit == null ? sorted : sorted.take(limit)).toList());
  }

  @override
  Future<Result<void>> save(SearchHistory history, {int maxItems = 500}) async {
    items.add(history);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeSearchRepository repository;
  late SearchService service;

  setUp(() {
    repository = FakeSearchRepository();
    service = SearchService(repository);
  });

  test('parses query and removes duplicates', () {
    expect(service.parseTags('  cat   cute cat '), ['cat', 'cute']);
  });

  test('recent searches are ordered by searchedAt', () async {
    await service.saveSearch('old', 1);
    await Future<void>.delayed(const Duration(milliseconds: 1));
    await service.saveSearch('new', 2);

    final result = await service.recentSearches();
    expect((result as Success<List<SearchHistory>>).data.first.query, 'new');
  });

  test('autocomplete is provider-only and returns empty without manager',
      () async {
    await service.saveSearch('cat cute', 2);
    await service.saveSearch('car', 1);

    final result = await service.autocomplete('ca');
    expect((result as Success<List<String>>).data, isEmpty);
  });

  test('clear history removes all searches', () async {
    await service.saveSearch('cat', 1);
    await service.clearHistory();

    final result = await service.recentSearches();
    expect((result as Success<List<SearchHistory>>).data, isEmpty);
  });
}
