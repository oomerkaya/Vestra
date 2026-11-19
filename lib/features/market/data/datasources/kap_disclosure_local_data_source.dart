import 'package:drift/drift.dart';
import 'package:vestra/core/database/app_database.dart';

/// Stored KAP disclosures (`kap_disclosures`) and the last fetch time per
/// stock (`app_settings` → `kap_fetched_at:<SYMBOL>`).
class KapDisclosureLocalDataSource {
  const KapDisclosureLocalDataSource(this._db);

  static const String fetchedAtPrefix = 'kap_fetched_at:';

  final AppDatabase _db;

  Stream<List<KapDisclosureRow>> watchAll() =>
      (_db.select(_db.kapDisclosures)..orderBy([
            (t) => OrderingTerm.desc(t.publishedAt),
            (t) => OrderingTerm.asc(t.symbol),
          ]))
          .watch();

  /// Replaces [symbol]'s disclosures and records the fetch time, atomically.
  Future<void> replaceForSymbol(
    String symbol,
    List<KapDisclosuresCompanion> rows,
    DateTime fetchedAt,
  ) => _db.transaction(() async {
    await (_db.delete(
      _db.kapDisclosures,
    )..where((t) => t.symbol.equals(symbol))).go();
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.kapDisclosures, rows),
    );
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: '$fetchedAtPrefix$symbol',
            value: fetchedAt.toUtc().toIso8601String(),
          ),
        );
  });

  Future<DateTime?> fetchedAt(String symbol) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals('$fetchedAtPrefix$symbol'))).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  /// Deletes disclosures and fetch times of every symbol not in [symbols].
  Future<void> keepOnly(Set<String> symbols) => _db.transaction(() async {
    await (_db.delete(
      _db.kapDisclosures,
    )..where((t) => t.symbol.isNotIn(symbols))).go();
    await (_db.delete(_db.appSettings)..where(
          (s) =>
              s.key.like('$fetchedAtPrefix%') &
              s.key.isNotIn([for (final x in symbols) '$fetchedAtPrefix$x']),
        ))
        .go();
  });
}
