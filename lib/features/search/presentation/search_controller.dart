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
    final rawLast =
        query.trim().isEmpty ? '' : query.trim().split(RegExp(r'\s+')).last;
    final cleanToken = SearchService.sanitizeToken(rawLast);
    final requestId = ++_suggestionRequestId;
    _suggestionDebounce?.cancel();

    if (cleanToken.isEmpty || cleanToken == 'and') {
      state = AsyncData(
        (state.value ?? const SearchState()).copyWith(
          query: query,
          suggestions: const [],
        ),
      );
      return;
    }

    // Instant local suggestions from disk cache & history (0 ms)
    final localMatches = ref
        .read(searchServiceProvider)
        .instantSuggestions(cleanToken, limit: 16);

    state = AsyncData(
      (state.value ?? const SearchState()).copyWith(
        query: query,
        suggestions: localMatches,
      ),
    );

    _suggestionDebounce = Timer(const Duration(milliseconds: 160), () async {
      final settingsRes = await ref.read(settingsServiceProvider).getSettings();
      final appSettings = settingsRes is Success<AppSettings>
          ? settingsRes.data
          : AppSettings.defaults;
      final suggestionsResult = await ref
          .read(searchServiceProvider)
          .autocompleteDetailed(
            cleanToken,
            limit: 16,
            tagCacheLimit: appSettings.tagCacheLimit,
          );
      if (requestId != _suggestionRequestId) return;
      final suggestions = suggestionsResult is Success<List<TagSuggestion>>
          ? suggestionsResult.data
          : localMatches;
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
