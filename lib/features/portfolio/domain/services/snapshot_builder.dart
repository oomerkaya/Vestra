import 'package:capira/core/domain/instrument.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_snapshot.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:decimal/decimal.dart';

/// Turns the current valuation into the day's snapshot. Pure.
abstract final class SnapshotBuilder {
  /// Turkey has used UTC+3 all year since 2016.
  static const Duration _istanbulOffset = Duration(hours: 3);

  /// `YYYY-MM-DD` of [instant] in Istanbul.
  static String dayKey(DateTime instant) {
    final local = instant.toUtc().add(_istanbulOffset);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }

  /// `null` when there is nothing worth storing (no priced holding).
  static (PortfolioSnapshot, List<AssetSnapshot>)? build({
    required PortfolioSummary summary,
    required List<Quote> quotes,
    required DateTime now,
  }) {
    if (summary.totalValue <= Decimal.zero) return null;
    final day = dayKey(now);
    Decimal? rate(String code) => quotes
        .where((q) => q.instrument == (type: AssetType.currency, code: code))
        .firstOrNull
        ?.priceTry;
    return (
      PortfolioSnapshot(
        day: day,
        valueTry: summary.totalValue,
        costTry: summary.totalCost,
        usdTry: rate('USD'),
        eurTry: rate('EUR'),
      ),
      [
        for (final v in summary.holdings)
          if (v.quote case final quote?)
            AssetSnapshot(
              day: day,
              instrument: quote.instrument,
              quantity: v.holding.quantity,
              priceTry: quote.priceTry,
            ),
      ],
    );
  }
}
