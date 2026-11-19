import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/entities/holding.dart';

abstract interface class PortfolioRepository {
  /// Emits every asset with its transactions whenever the data changes.
  Stream<Result<List<AssetWithTransactions>>> watchPortfolio();

  Future<Result<List<AssetTransaction>>> getTransactions(int assetId);

  /// Returns the existing asset for `(type, code)` or creates it.
  Future<Result<Asset>> findOrCreateAsset(AssetDraft draft);

  /// Returns the new transaction id.
  Future<Result<int>> insertTransaction(int assetId, TransactionDraft draft);

  Future<Result<void>> updateTransaction(AssetTransaction transaction);

  Future<Result<void>> deleteTransaction(int transactionId);

  /// Deletes the asset and all of its transactions.
  Future<Result<void>> deleteAsset(int assetId);
}
