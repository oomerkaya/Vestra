import 'package:decimal/decimal.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/portfolio/domain/entities/holding.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_summary.dart';

/// Pure valuation of holdings against cached quotes.
///
/// - Only open holdings (quantity > 0) are included.
/// - Holdings without a price are listed but left out of every total and
///   counted in `missingPriceCount`.
/// - P/L totals only cover holdings with a price AND a known cost, so the
///   percentage is never distorted by unknown costs.
/// - Daily change uses the quote's daily %: previous = price / (1 + p/100).
abstract final class PortfolioValuator {
  static const int scale = 10;
  static final Decimal _hundred = Decimal.fromInt(100);

  static PortfolioSummary value(List<Holding> holdings, List<Quote> quotes) {
    final byInstrument = <Instrument, Quote>{
      for (final q in quotes) q.instrument: q,
    };

    final valued = <ValuedHolding>[];
    var totalValue = Decimal.zero;
    var costOfPriced = Decimal.zero;
    var valueWithKnownCost = Decimal.zero;
    var anyKnownCost = false;
    var dailyChange = Decimal.zero;
    var anyDaily = false;
    var missing = 0;
    final byCategory = <QuoteCategory, Decimal>{};

    for (final h in holdings) {
      if (h.quantity <= Decimal.zero) continue;
      final instrument = (type: h.asset.type, code: h.asset.code);
      final quote = byInstrument[instrument];
      if (quote == null) {
        missing++;
        valued.add(ValuedHolding(holding: h));
        continue;
      }

      final value = h.quantity * quote.priceTry;
      totalValue += value;
      final category = QuoteCategory.of(h.asset.type);
      byCategory[category] = (byCategory[category] ?? Decimal.zero) + value;

      Decimal? pnl;
      Decimal? pnlPercent;
      final cost = h.totalCostTry;
      if (cost != null) {
        pnl = value - cost;
        anyKnownCost = true;
        costOfPriced += cost;
        valueWithKnownCost += value;
        if (cost > Decimal.zero) pnlPercent = _percent(pnl, cost);
      }

      Decimal? daily;
      final pct = quote.changePercent;
      if (pct != null) {
        final previous = _divide(
          quote.priceTry * _hundred,
          _hundred + pct,
        );
        daily = h.quantity * (quote.priceTry - previous);
        dailyChange += daily;
        anyDaily = true;
      }

      valued.add(
        ValuedHolding(
          holding: h,
          quote: quote,
          marketValue: value,
          unrealizedPnl: pnl,
          unrealizedPnlPercent: pnlPercent,
          dailyChange: daily,
        ),
      );
    }

    valued.sort((a, b) {
      final av = a.marketValue;
      final bv = b.marketValue;
      if (av == null && bv == null) {
        return a.holding.asset.name.compareTo(b.holding.asset.name);
      }
      if (av == null) return 1;
      if (bv == null) return -1;
      return bv.compareTo(av);
    });

    final unrealized = anyKnownCost ? valueWithKnownCost - costOfPriced : null;
    final previousTotal = totalValue - dailyChange;
    return PortfolioSummary(
      holdings: valued,
      totalValue: totalValue,
      valueByCategory: byCategory,
      missingPriceCount: missing,
      totalCost: anyKnownCost ? costOfPriced : null,
      unrealizedPnl: unrealized,
      unrealizedPnlPercent: unrealized != null && costOfPriced > Decimal.zero
          ? _percent(unrealized, costOfPriced)
          : null,
      dailyChange: anyDaily ? dailyChange : null,
      dailyChangePercent: anyDaily && previousTotal > Decimal.zero
          ? _percent(dailyChange, previousTotal)
          : null,
    );
  }

  static Decimal _percent(Decimal part, Decimal whole) =>
      _divide(part * _hundred, whole);

  static Decimal _divide(Decimal a, Decimal b) =>
      (a / b).toDecimal(scaleOnInfinitePrecision: scale);
}
