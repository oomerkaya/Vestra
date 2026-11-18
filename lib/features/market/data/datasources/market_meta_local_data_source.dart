import 'package:vestra/core/database/app_database.dart';

/// Small market bookkeeping values in `app_settings`.
class MarketMetaLocalDataSource {
  const MarketMetaLocalDataSource(this._db);

  /// When the whole BIST market was last fetched successfully. Separate
  /// from the cached rows: older app versions cached only held stocks, so
  /// "some stock prices exist" does not mean a full snapshot exists.
  static const String stocksSnapshotKey = 'stocks_snapshot_at';

  final AppDatabase _db;

  Future<DateTime?> stocksSnapshotAt() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(stocksSnapshotKey))).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  Future<void> setStocksSnapshotAt(DateTime at) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: stocksSnapshotKey,
          value: at.toUtc().toIso8601String(),
        ),
      );
}
