import '../../core/utils/result.dart';
import '../models/search_history.dart';
import '../models/tag_suggestion.dart';
import '../providers/provider_manager.dart';
import '../repositories/search_repository.dart';

class SearchService {
  SearchService(this._repository, [this._providerManager]);

  final SearchRepository _repository;
  final ProviderManager? _providerManager;

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

  Future<Result<List<SearchHistory>>> recentSearches({int? limit}) {
    return _repository.recent(limit: limit);
  }

  Future<Result<List<String>>> autocomplete(String prefix,
      {int limit = 10}) async {
    final result = await autocompleteDetailed(prefix, limit: limit);
    return result.fold(
      onSuccess: (items) => Success(items.map((item) => item.name).toList()),
      onError: Error<List<String>>.new,
    );
  }

  Future<Result<List<TagSuggestion>>> autocompleteDetailed(
    String prefix, {
    int limit = 10,
  }) async {
    final manager = _providerManager;
    if (manager == null || prefix.trim().isEmpty) return const Success([]);
    return manager.suggestTags(prefix.trim(), limit: limit);
  }

  Future<Result<void>> clearHistory() => _repository.clear();
}
