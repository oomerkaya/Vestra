import 'package:capira/core/database/app_database.dart';
import 'package:drift/drift.dart';

class PriceCacheLocalDataSource {
  const PriceCacheLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<PriceCacheRow>> watchAll() => _db.select(_db.priceCache).watch();

  /// Deletes rows of the given [types] whose code is not in [keep]. Used
  /// after a full list was fetched, so instruments the provider no longer
  /// lists (delisted stocks, dropped symbols) leave the cache.
  Future<int> deleteMissing(Set<String> types, Set<String> keep) => (_db.delete(
    _db.priceCache,
  )..where((p) => p.type.isIn(types) & p.code.isNotIn(keep))).go();

  /// Inserts or replaces rows by `(type, code)` in one transaction.
  Future<void> upsertAll(List<PriceCacheCompanion> rows) => _db.batch(
    (batch) => batch.insertAllOnConflictUpdate(_db.priceCache, rows),
  );
}
