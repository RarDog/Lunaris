import 'package:isar/isar.dart';

import '../errors/app_exception.dart';
import '../utils/result.dart';
import 'app_database.dart';

class DatabaseService {
  DatabaseService(this.database);

  final AppDatabase database;

  Isar get isar => database.isar;

  Future<Result<T>> safeRead<T>(Future<T> Function(Isar isar) action) async {
    try {
      return Success(await action(isar));
    } catch (error) {
      return Error(
          DatabaseException(error.toString(), details: error).toFailure());
    }
  }

  Future<Result<T>> safeWrite<T>(Future<T> Function(Isar isar) action) async {
    try {
      final value = await isar.writeTxn(() => action(isar));
      return Success(value);
    } catch (error) {
      return Error(
          DatabaseException(error.toString(), details: error).toFailure());
    }
  }
}
