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
      final norm = history.query.trim().toLowerCase();
      // Remove any existing duplicate records with same query
      final all = await isar.searchHistoryEntitys.where().findAll();
      for (final item in all) {
        if (item.query.trim().toLowerCase() == norm) {
          await isar.searchHistoryEntitys.delete(item.isarId);
        }
      }

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

      final seen = <String>{};
      final deduplicated = <SearchHistoryEntity>[];
      for (final item in items) {
        final key = item.query.trim().toLowerCase();
        if (key.isEmpty) continue;
        if (seen.add(key)) {
          deduplicated.add(item);
        }
      }

      final limited = limit == null ? deduplicated : deduplicated.take(limit);
      return limited.map((entity) => entity.toModel()).toList();
    });
  }

  Future<Result<bool>> delete(String historyId) {
    return _databaseService.safeWrite((isar) async {
      final target = await isar.searchHistoryEntitys
          .where()
          .filter()
          .historyIdEqualTo(historyId)
          .findFirst();
      if (target != null) {
        final norm = target.query.trim().toLowerCase();
        final all = await isar.searchHistoryEntitys.where().findAll();
        for (final item in all) {
          if (item.query.trim().toLowerCase() == norm ||
              item.historyId == historyId) {
            await isar.searchHistoryEntitys.delete(item.isarId);
          }
        }
        return true;
      }
      return await isar.searchHistoryEntitys.deleteByHistoryId(historyId);
    });
  }

  Future<Result<void>> clear() {
    return _databaseService.safeWrite((isar) async {
      await isar.searchHistoryEntitys.clear();
    });
  }
}
