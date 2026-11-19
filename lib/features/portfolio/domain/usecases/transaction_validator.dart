import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/entities/transaction_validation_failure.dart';
import 'package:capira/features/portfolio/domain/services/holding_calculator.dart';
import 'package:decimal/decimal.dart';

/// Shared checks for add / update / delete.
abstract final class TransactionValidator {
  /// Validates a single transaction's own fields.
  static TransactionValidationFailure? validateFields({
    required Decimal quantity,
    required Decimal? unitPriceTry,
  }) {
    if (quantity <= Decimal.zero) {
      return const TransactionValidationFailure(
        TransactionValidationReason.nonPositiveQuantity,
      );
    }
    if (unitPriceTry != null && unitPriceTry < Decimal.zero) {
      return const TransactionValidationFailure(
        TransactionValidationReason.negativePrice,
      );
    }
    return null;
  }

  /// Validates that the resulting history never sells more than held.
  static TransactionValidationFailure? validateHistory(
    List<AssetTransaction> resulting,
  ) => HoldingCalculator.wouldOversell(resulting)
      ? const TransactionValidationFailure(TransactionValidationReason.oversell)
      : null;
}
