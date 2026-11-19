import 'package:capira/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Raw Drift access for the portfolio tables. Throws on DB errors; the
/// repository converts exceptions into failures.
class PortfolioLocalDataSource {
  const PortfolioLocalDataSource(this._db);

  final AppDatabase _db;

  /// Assets with their transactions (assets without transactions included).
  Stream<List<(AssetRow, List<TransactionRow>)>>
  watchAssetsWithTransactions() =>
      _assetsWithTransactions().watch().map(_group);

  /// One-off read of [watchAssetsWithTransactions].
  Future<List<(AssetRow, List<TransactionRow>)>> getAssetsWithTransactions() =>
      _assetsWithTransactions().get().then(_group);

  JoinedSelectStatement<HasResultSet, dynamic> _assetsWithTransactions() =>
      _db.select(_db.assets).join([
        leftOuterJoin(
          _db.assetTransactions,
          _db.assetTransactions.assetId.equalsExp(_db.assets.id),
        ),
      ])..orderBy([OrderingTerm.asc(_db.assets.id)]);

  List<(AssetRow, List<TransactionRow>)> _group(List<TypedResult> rows) {
    final grouped = <int, (AssetRow, List<TransactionRow>)>{};
    for (final row in rows) {
      final asset = row.readTable(_db.assets);
      final entry = grouped.putIfAbsent(asset.id, () => (asset, []));
      final tx = row.readTableOrNull(_db.assetTransactions);
      if (tx != null) entry.$2.add(tx);
    }
    return grouped.values.toList();
  }

  Future<List<TransactionRow>> getTransactions(int assetId) => (_db.select(
    _db.assetTransactions,
  )..where((t) => t.assetId.equals(assetId))).get();

  Future<AssetRow> findOrCreateAsset({
    required String type,
    required String code,
    required String name,
  }) => _db.transaction(() async {
    final existing =
        await (_db.select(_db.assets)
              ..where((a) => a.type.equals(type) & a.code.equals(code)))
            .getSingleOrNull();
    if (existing != null) return existing;
    return _db
        .into(_db.assets)
        .insertReturning(
          AssetsCompanion.insert(type: type, code: code, name: name),
        );
  });

  Future<int> insertTransaction(AssetTransactionsCompanion companion) =>
      _db.into(_db.assetTransactions).insert(companion);

  /// Returns the number of updated rows.
  Future<int> updateTransaction(int id, AssetTransactionsCompanion companion) =>
      (_db.update(
        _db.assetTransactions,
      )..where((t) => t.id.equals(id))).write(companion);

  Future<int> deleteTransaction(int id) => (_db.delete(
    _db.assetTransactions,
  )..where((t) => t.id.equals(id))).go();

  /// Transactions are removed by the `ON DELETE CASCADE` foreign key.
  Future<int> deleteAsset(int id) =>
      (_db.delete(_db.assets)..where((a) => a.id.equals(id))).go();

  /// Deletes every asset and transaction and inserts [assets] instead, all
  /// or nothing. The `assetId` of the given transaction companions is
  /// replaced with the new asset's id.
  Future<void> replaceAll(
    List<
      ({
        String type,
        String code,
        String name,
        List<AssetTransactionsCompanion> transactions,
      })
    >
    assets,
  ) => _db.transaction(() async {
    await _db.delete(_db.assetTransactions).go();
    await _db.delete(_db.assets).go();
    for (final a in assets) {
      final id = await _db
          .into(_db.assets)
          .insert(
            AssetsCompanion.insert(type: a.type, code: a.code, name: a.name),
          );
      for (final tx in a.transactions) {
        await _db
            .into(_db.assetTransactions)
            .insert(tx.copyWith(assetId: Value(id)));
      }
    }
  });
}
