import 'package:isar/isar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/result.dart';
import '../models/search_history.dart';

class SearchRepository {
  SearchRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<Result<void>> save(SearchHistory history) {
    return _databaseService.safeWrite((isar) async {
      await isar.searchHistoryEntitys.put(
        SearchHistoryEntity()
          ..historyId = history.id
          ..query = history.query
          ..tags = history.tags
          ..searchedAt = history.searchedAt
          ..resultCount = history.resultCount,
      );
    });
  }

  Future<Result<List<SearchHistory>>> recent({int? limit}) {
    return _databaseService.safeRead((isar) async {
      final items = await isar.searchHistoryEntitys.where().findAll();
      items.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
      final limited = limit == null ? items : items.take(limit);
      return limited.map((entity) => entity.toModel()).toList();
    });
  }

  Future<Result<void>> clear() {
    return _databaseService.safeWrite((isar) async {
      await isar.searchHistoryEntitys.clear();
    });
  }
}
