import 'package:capira/core/error/failure.dart';

enum TransactionValidationReason {
  /// Quantity is zero or negative.
  nonPositiveQuantity,

  /// Unit price is negative.
  negativePrice,

  /// A sell would exceed the quantity held at that date.
  oversell,
}

final class TransactionValidationFailure extends ValidationFailure {
  const TransactionValidationFailure(this.reason) : super();

  final TransactionValidationReason reason;
}
