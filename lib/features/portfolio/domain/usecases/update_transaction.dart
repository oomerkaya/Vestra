import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:capira/features/portfolio/domain/usecases/transaction_validator.dart';

class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final PortfolioRepository _repository;

  Future<Result<void>> call(AssetTransaction updated) async {
    final fieldError = TransactionValidator.validateFields(
      quantity: updated.quantity,
      unitPriceTry: updated.unitPriceTry,
    );
    if (fieldError != null) return Err(fieldError);

    final existing = await _repository.getTransactions(updated.assetId);
    switch (existing) {
      case Err(:final failure):
        return Err(failure);
      case Success(:final value):
        final resulting = value
            .map((tx) => tx.id == updated.id ? updated : tx)
            .toList();
        final historyError = TransactionValidator.validateHistory(resulting);
        if (historyError != null) return Err(historyError);
    }

    return _repository.updateTransaction(updated);
  }
}
