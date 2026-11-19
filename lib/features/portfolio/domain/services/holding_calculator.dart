import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/portfolio/domain/entities/holding.dart';
import 'package:decimal/decimal.dart';

/// Pure weighted-average-cost calculation over a transaction list.
///
/// Transactions are processed in chronological order (date, then id).
/// A sell reduces the cost basis at the current average cost; the difference
/// to the sell price is realized P/L.
abstract final class HoldingCalculator {
  /// Scale used when a division does not terminate (e.g. 100 / 3).
  static const int divisionScale = 10;

  static Holding calculate(Asset asset, List<AssetTransaction> transactions) {
    var quantity = Decimal.zero;
    var cost = Decimal.zero;
    var costKnown = true;
    var realized = Decimal.zero;
    var realizedKnown = true;

    for (final tx in sortChronologically(transactions)) {
      switch (tx.kind) {
        case TransactionKind.buy:
          quantity += tx.quantity;
          final price = tx.unitPriceTry;
          if (price == null) {
            costKnown = false;
          } else {
            cost += tx.quantity * price;
          }
        case TransactionKind.sell:
          if (quantity == Decimal.zero) continue; // oversell; see wouldOversell
          final soldQty = tx.quantity > quantity ? quantity : tx.quantity;
          final avg = _divide(cost, quantity);
          cost -= avg * soldQty;
          quantity -= soldQty;
          final price = tx.unitPriceTry;
          if (price == null || !costKnown) {
            realizedKnown = false;
          } else {
            realized += (price - avg) * soldQty;
          }
      }
      if (quantity == Decimal.zero) {
        // Fully closed: earlier unknown costs no longer affect the position.
        cost = Decimal.zero;
        costKnown = true;
      }
    }

    final hasQuantity = quantity > Decimal.zero;
    return Holding(
      asset: asset,
      quantity: quantity,
      transactionCount: transactions.length,
      totalCostTry: costKnown ? cost : null,
      averageCostTry: costKnown && hasQuantity ? _divide(cost, quantity) : null,
      realizedPnlTry: realizedKnown ? realized : null,
    );
  }

  /// True if, at any point in time, a sell exceeds the quantity held.
  static bool wouldOversell(List<AssetTransaction> transactions) {
    var quantity = Decimal.zero;
    for (final tx in sortChronologically(transactions)) {
      quantity += tx.kind == TransactionKind.buy ? tx.quantity : -tx.quantity;
      if (quantity < Decimal.zero) return true;
    }
    return false;
  }

  static List<AssetTransaction> sortChronologically(
    List<AssetTransaction> transactions,
  ) => [...transactions]
    ..sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });

  static Decimal _divide(Decimal a, Decimal b) =>
      (a / b).toDecimal(scaleOnInfinitePrecision: divisionScale);
}
