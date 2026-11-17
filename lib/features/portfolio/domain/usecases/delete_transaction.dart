import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:vestra/features/portfolio/domain/usecases/transaction_validator.dart';

/// Deletes a transaction unless doing so would leave a later sell uncovered
/// (e.g. deleting the only buy before a sell).
class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final PortfolioRepository _repository;

  Future<Result<void>> call(AssetTransaction transaction) async {
    final existing = await _repository.getTransactions(transaction.assetId);
    switch (existing) {
      case Err(:final failure):
        return Err(failure);
      case Success(:final value):
        final resulting = value.where((tx) => tx.id != transaction.id).toList();
        final historyError = TransactionValidator.validateHistory(resulting);
        if (historyError != null) return Err(historyError);
    }

    return _repository.deleteTransaction(transaction.id);
  }
}
