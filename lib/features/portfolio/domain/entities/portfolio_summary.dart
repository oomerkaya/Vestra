import 'package:decimal/decimal.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/portfolio/domain/entities/holding.dart';

/// A holding combined with its latest cached price. All money in TRY.
class ValuedHolding {
  const ValuedHolding({
    required this.holding,
    this.quote,
    this.marketValue,
    this.unrealizedPnl,
    this.unrealizedPnlPercent,
    this.dailyChange,
  });

  final Holding holding;

  /// `null` when no price is cached yet (e.g. no API key for gold).
  final Quote? quote;

  /// quantity × price; `null` without a price.
  final Decimal? marketValue;

  /// marketValue − totalCost; `null` without a price or a known cost.
  final Decimal? unrealizedPnl;
  final Decimal? unrealizedPnlPercent;

  /// Value change since the previous close, from the quote's daily %.
  final Decimal? dailyChange;

  bool get hasPrice => marketValue != null;
}

/// Totals over all open holdings.
class PortfolioSummary {
  const PortfolioSummary({
    required this.holdings,
    required this.totalValue,
    required this.valueByCategory,
    required this.missingPriceCount,
    this.totalCost,
    this.unrealizedPnl,
    this.unrealizedPnlPercent,
    this.dailyChange,
    this.dailyChangePercent,
  });

  static final empty = PortfolioSummary(
    holdings: const [],
    totalValue: Decimal.zero,
    valueByCategory: const {},
    missingPriceCount: 0,
  );

  /// Open holdings (quantity > 0), highest value first, unpriced last.
  final List<ValuedHolding> holdings;

  /// Sum of market values of priced holdings.
  final Decimal totalValue;

  final Map<QuoteCategory, Decimal> valueByCategory;

  /// Holdings that have no cached price and are left out of totals.
  final int missingPriceCount;

  /// Cost of the priced holdings whose cost is known.
  final Decimal? totalCost;
  final Decimal? unrealizedPnl;
  final Decimal? unrealizedPnlPercent;
  final Decimal? dailyChange;
  final Decimal? dailyChangePercent;

  bool get isEmpty => holdings.isEmpty;
}
