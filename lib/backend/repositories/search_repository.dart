import 'package:isar/isar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/utils/result.dart';
import '../models/search_history.dart';

class SearchRepository {
  SearchRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<Result<void>> save(SearchHistory history, {int maxItems = 500}) {
    return _databaseService.safeWrite((isar) async {
      await isar.searchHistoryEntitys.put(
        SearchHistoryEntity()
          ..historyId = history.id
          ..query = history.query
          ..tags = history.tags
          ..searchedAt = history.searchedAt
          ..resultCount = history.resultCount,
      );
      final count = await isar.searchHistoryEntitys.count();
      if (count > maxItems) {
        final items = await isar.searchHistoryEntitys.where().findAll();
        items.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
        final toRemove = items.skip(maxItems);
        for (final item in toRemove) {
          await isar.searchHistoryEntitys.delete(item.isarId);
        }
      }
    });
  }

  Future<Result<int>> count() {
    return _databaseService.safeRead((isar) async {
      return await isar.searchHistoryEntitys.count();
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

  Future<Result<bool>> delete(String historyId) {
    return _databaseService.safeWrite((isar) async {
      return await isar.searchHistoryEntitys.deleteByHistoryId(historyId);
    });
  }

  Future<Result<void>> clear() {
    return _databaseService.safeWrite((isar) async {
      await isar.searchHistoryEntitys.clear();
    });
  }
}
