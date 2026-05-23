import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import 'search_state.dart';

final searchControllerProvider =
    AsyncNotifierProvider<SearchController, SearchState>(SearchController.new);

class SearchController extends AsyncNotifier<SearchState> {
  @override
  Future<SearchState> build() async {
    final recent = await _recent();
    return SearchState(recent: recent);
  }

  Future<void> updateQuery(String query) async {
    final lastToken =
        query.trim().isEmpty ? '' : query.trim().split(RegExp(r'\s+')).last;
    final suggestionsResult = await ref
        .read(searchServiceProvider)
        .autocompleteDetailed(lastToken, limit: 16);
    final suggestions = suggestionsResult is Success<List<TagSuggestion>>
        ? suggestionsResult.data
        : <TagSuggestion>[];
    state = AsyncData(
      (state.value ?? const SearchState()).copyWith(
        query: query,
        suggestions: suggestions,
      ),
    );
  }

  Future<void> clearHistory() async {
    await ref.read(searchServiceProvider).clearHistory();
    state = const AsyncData(SearchState());
  }

  Future<List<SearchHistory>> _recent() async {
    final result = await ref.read(searchServiceProvider).recentSearches();
    return result is Success<List<SearchHistory>> ? result.data : const [];
  }
}
