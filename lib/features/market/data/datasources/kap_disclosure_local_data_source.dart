import 'package:drift/drift.dart';
import 'package:vestra/core/database/app_database.dart';

/// Stored KAP disclosures (`kap_disclosures`) and bookkeeping values in
/// `app_settings`: `kap_fetched_at:<SYMBOL>` (stock fetched on its own),
/// `kap_feed_at` (general feed read) and `kap_seen_at` (list opened).
class KapDisclosureLocalDataSource {
  const KapDisclosureLocalDataSource(this._db);

  static const String fetchedAtPrefix = 'kap_fetched_at:';
  static const String feedAtKey = 'kap_feed_at';
  static const String seenAtKey = 'kap_seen_at';

  final AppDatabase _db;

  Stream<List<KapDisclosureRow>> watchAll() =>
      (_db.select(_db.kapDisclosures)..orderBy([
            (t) => OrderingTerm.desc(t.publishedAt),
            (t) => OrderingTerm.asc(t.symbol),
          ]))
          .watch();

  /// Inserts or updates [rows] and, if given, records [stampKey] = [at],
  /// atomically.
  Future<void> upsertAll(
    List<KapDisclosuresCompanion> rows, {
    required DateTime at,
    String? stampKey,
  }) => _db.transaction(() async {
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.kapDisclosures, rows),
    );
    if (stampKey != null) await _setTime(stampKey, at);
  });

  Future<DateTime?> fetchedAt(String symbol) =>
      _time('$fetchedAtPrefix$symbol');

  Future<DateTime?> feedAt() => _time(feedAtKey);

  Stream<DateTime?> watchSeenAt() =>
      (_db.select(_db.appSettings)..where((s) => s.key.equals(seenAtKey)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : DateTime.tryParse(row.value));

  Future<void> setSeenAt(DateTime at) => _setTime(seenAtKey, at);

  /// Deletes disclosures of every symbol not in [symbols], those published
  /// before [before], and fetch times of symbols no longer held.
  Future<void> keepOnly(Set<String> symbols, {required DateTime before}) =>
      _db.transaction(() async {
        await (_db.delete(_db.kapDisclosures)..where(
              (t) =>
                  t.symbol.isNotIn(symbols) |
                  t.publishedAt.isSmallerThanValue(before),
            ))
            .go();
        await (_db.delete(_db.appSettings)..where(
              (s) =>
                  s.key.like('$fetchedAtPrefix%') &
                  s.key.isNotIn([
                    for (final x in symbols) '$fetchedAtPrefix$x',
                  ]),
            ))
            .go();
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
