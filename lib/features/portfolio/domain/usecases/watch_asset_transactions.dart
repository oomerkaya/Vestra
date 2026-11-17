import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:vestra/features/portfolio/domain/services/holding_calculator.dart';

/// Transactions of one asset, newest first, kept in sync with the DB.
class WatchAssetTransactions {
  const WatchAssetTransactions(this._repository);

  final PortfolioRepository _repository;

  Stream<Result<List<AssetTransaction>>> call(int assetId) =>
      _repository.watchPortfolio().map(
        (result) => result.map((items) {
          final match = items.where((i) => i.asset.id == assetId);
          if (match.isEmpty) return const <AssetTransaction>[];
          return HoldingCalculator.sortChronologically(
            match.first.transactions,
          ).reversed.toList();
        }),
      );
}
