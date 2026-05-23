class SearchHistory {
  const SearchHistory({
    required this.id,
    required this.query,
    required this.tags,
    required this.searchedAt,
    required this.resultCount,
  });

  final String id;
  final String query;
  final List<String> tags;
  final DateTime searchedAt;
  final int resultCount;
}
