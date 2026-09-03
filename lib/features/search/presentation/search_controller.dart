import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import 'search_state.dart';

final searchControllerProvider =
    AsyncNotifierProvider<SearchController, SearchState>(SearchController.new);

class SearchController extends AsyncNotifier<SearchState> {
  Timer? _suggestionDebounce;
  int _suggestionRequestId = 0;

  @override
  Future<SearchState> build() async {
    ref.onDispose(() => _suggestionDebounce?.cancel());
    final recent = await _recent();
    return SearchState(recent: recent);
  }

  Future<void> updateQuery(String query) async {
    final lastToken =
        query.trim().isEmpty ? '' : query.trim().split(RegExp(r'\s+')).last;
    final requestId = ++_suggestionRequestId;
    _suggestionDebounce?.cancel();
    if (lastToken.isEmpty) {
      state = AsyncData(
        (state.value ?? const SearchState()).copyWith(
          query: query,
          suggestions: const [],
        ),
      );
      return;
    }
    state = AsyncData(
      (state.value ?? const SearchState()).copyWith(
        query: query,
      ),
    );
    _suggestionDebounce = Timer(const Duration(milliseconds: 280), () async {
      final suggestionsResult = await ref
          .read(searchServiceProvider)
          .autocompleteDetailed(lastToken, limit: 16);
      if (requestId != _suggestionRequestId) return;
      final normalizedToken = lastToken.trim().toLowerCase();
      final suggestions = suggestionsResult is Success<List<TagSuggestion>>
          ? suggestionsResult.data
              .where((item) => item.name.toLowerCase().startsWith(
                    normalizedToken,
                  ))
              .toList(growable: false)
          : <TagSuggestion>[];
      state = AsyncData(
        (state.value ?? const SearchState()).copyWith(
          query: query,
          suggestions: suggestions,
        ),
      );
    });
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
