import 'package:drift/drift.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/features/portfolio/domain/entities/asset.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';

/// DB stores enum names as TEXT. Renaming an enum value requires a
/// migration that rewrites existing rows.
extension AssetRowMapper on AssetRow {
  Asset toEntity() => Asset(
    id: id,
    type: AssetType.values.byName(type),
    code: code,
    name: name,
  );
}

extension TransactionRowMapper on TransactionRow {
  AssetTransaction toEntity() => AssetTransaction(
    id: id,
    assetId: assetId,
    kind: TransactionKind.values.byName(kind),
    quantity: quantity,
    unitPriceTry: unitPriceTry,
    date: date,
    note: note,
  );
}

extension TransactionDraftMapper on TransactionDraft {
  AssetTransactionsCompanion toCompanion(int assetId) =>
      AssetTransactionsCompanion.insert(
        assetId: assetId,
        kind: kind.name,
        quantity: quantity,
        unitPriceTry: Value(unitPriceTry),
        date: date,
        note: Value(note),
      );
}

extension AssetTransactionMapper on AssetTransaction {
  AssetTransactionsCompanion toUpdateCompanion() => AssetTransactionsCompanion(
    kind: Value(kind.name),
    quantity: Value(quantity),
    unitPriceTry: Value(unitPriceTry),
    date: Value(date),
    note: Value(note),
  );
}
