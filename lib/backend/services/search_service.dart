import '../../core/utils/result.dart';
import '../models/search_history.dart';
import '../repositories/search_repository.dart';

class SearchService {
  SearchService(this._repository);

  final SearchRepository _repository;

  List<String> parseTags(String query) {
    return query
        .trim()
        .split(RegExp(r'\s+'))
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<Result<void>> saveSearch(String query, int resultCount) {
    final tags = parseTags(query);
    return _repository.save(
      SearchHistory(
        id: '${DateTime.now().microsecondsSinceEpoch}:${tags.join(',')}',
        query: query.trim(),
        tags: tags,
        searchedAt: DateTime.now(),
        resultCount: resultCount,
      ),
    );
  }

  Future<Result<List<SearchHistory>>> recentSearches({int limit = 20}) {
    return _repository.recent(limit: limit);
  }

  Future<Result<List<String>>> autocomplete(String prefix,
      {int limit = 10}) async {
    final recent = await _repository.recent(limit: 100);
    return recent.fold(
      onSuccess: (items) {
        final needle = prefix.toLowerCase();
        final values = <String>{};
        for (final item in items) {
          for (final tag in item.tags) {
            if (tag.toLowerCase().startsWith(needle)) values.add(tag);
          }
        }
        return Success(values.take(limit).toList());
      },
      onError: Error<List<String>>.new,
    );
  }

  Future<Result<void>> clearHistory() => _repository.clear();
}
