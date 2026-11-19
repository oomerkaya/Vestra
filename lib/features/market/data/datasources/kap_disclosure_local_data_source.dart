import 'package:capira/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Stored KAP disclosures (`kap_disclosures`) and bookkeeping values in
/// `app_settings`: `kap_feed_at` (general feed read) and `kap_seen_at`
/// (list opened).
class KapDisclosureLocalDataSource {
  const KapDisclosureLocalDataSource(this._db);

  static const String feedAtKey = 'kap_feed_at';
  static const String seenAtKey = 'kap_seen_at';

  /// Per-stock fetch times of an earlier design; deleted on [prune].
  static const String _legacyPrefix = 'kap_fetched_at:';

  final AppDatabase _db;

  Stream<List<KapDisclosureRow>> watchForSymbols(Set<String> symbols) =>
      (_db.select(_db.kapDisclosures)
            ..where((t) => t.symbol.isIn(symbols))
            ..orderBy([
              (t) => OrderingTerm.desc(t.publishedAt),
              (t) => OrderingTerm.asc(t.symbol),
            ]))
          .watch();

  /// Inserts or updates [rows] and records the feed time, atomically.
  Future<void> storeFeed(
    List<KapDisclosuresCompanion> rows, {
    required DateTime at,
  }) => _db.transaction(() async {
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.kapDisclosures, rows),
    );
    await _setTime(feedAtKey, at);
  });

  Future<DateTime?> feedAt() => _time(feedAtKey);

  Stream<DateTime?> watchSeenAt() =>
      (_db.select(_db.appSettings)..where((s) => s.key.equals(seenAtKey)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : DateTime.tryParse(row.value));

  Future<void> setSeenAt(DateTime at) => _setTime(seenAtKey, at);

  /// Deletes disclosures published before [before].
  Future<void> prune({required DateTime before}) => _db.transaction(() async {
    await (_db.delete(
      _db.kapDisclosures,
    )..where((t) => t.publishedAt.isSmallerThanValue(before))).go();
    await (_db.delete(
      _db.appSettings,
    )..where((s) => s.key.like('$_legacyPrefix%'))).go();
  });

  Future<DateTime?> _time(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  Future<void> _setTime(String key, DateTime at) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: key,
          value: at.toUtc().toIso8601String(),
        ),
      );
}
