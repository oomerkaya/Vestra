import 'package:drift/drift.dart';
import 'package:vestra/core/database/app_database.dart';

class PriceCacheLocalDataSource {
  const PriceCacheLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<PriceCacheRow>> watchAll() => _db.select(_db.priceCache).watch();

  Future<PriceCacheRow?> find(String type, String code) => (_db.select(
    _db.priceCache,
  )..where((p) => p.type.equals(type) & p.code.equals(code))).getSingleOrNull();

  /// Inserts or replaces rows by `(type, code)` in one transaction.
  Future<void> upsertAll(List<PriceCacheCompanion> rows) => _db.batch(
    (batch) => batch.insertAllOnConflictUpdate(_db.priceCache, rows),
  );
}
