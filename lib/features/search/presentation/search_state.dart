import '../../../backend/backend.dart';

class SearchState {
  const SearchState({
    this.recent = const [],
    this.suggestions = const [],
    this.query = '',
  });

  final List<SearchHistory> recent;
  final List<String> suggestions;
  final String query;

  SearchState copyWith({
    List<SearchHistory>? recent,
    List<String>? suggestions,
    String? query,
  }) {
    return SearchState(
      recent: recent ?? this.recent,
      suggestions: suggestions ?? this.suggestions,
      query: query ?? this.query,
    );
  }
}
