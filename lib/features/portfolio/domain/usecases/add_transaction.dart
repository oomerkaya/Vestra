import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:capira/features/portfolio/domain/usecases/transaction_validator.dart';

/// Records a buy or sell. Creates the asset on its first transaction.
/// "Add asset" in the UI is a buy through this use case.
class AddTransaction {
  const AddTransaction(this._repository);

  final PortfolioRepository _repository;

  Future<Result<int>> call(AssetDraft asset, TransactionDraft draft) async {
    final fieldError = TransactionValidator.validateFields(
      quantity: draft.quantity,
      unitPriceTry: draft.unitPriceTry,
    );
    if (fieldError != null) return Err(fieldError);

    final assetResult = await _repository.findOrCreateAsset(asset);
    final Asset saved;
    switch (assetResult) {
      case Success(:final value):
        saved = value;
      case Err(:final failure):
        return Err(failure);
    }

    final existing = await _repository.getTransactions(saved.id);
    final List<AssetTransaction> history;
    switch (existing) {
      case Success(:final value):
        history = value;
      case Err(:final failure):
        return Err(failure);
    }

    final candidate = AssetTransaction(
      // Sorts after every existing transaction on the same date.
      id: 1 << 53,
      assetId: saved.id,
      kind: draft.kind,
      quantity: draft.quantity,
      unitPriceTry: draft.unitPriceTry,
      date: draft.date,
    );
    final historyError = TransactionValidator.validateHistory([
      ...history,
      candidate,
    ]);
    if (historyError != null) return Err(historyError);

    return _repository.insertTransaction(saved.id, draft);
  }
}
