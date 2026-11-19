import 'package:capira/core/domain/instrument.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_snapshot.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:capira/features/portfolio/domain/services/snapshot_builder.dart';
import 'package:decimal/decimal.dart';

enum SummaryPeriod {
  week(7),
  month(30);

  const SummaryPeriod(this.days);

  final int days;
}

/// One instrument's price change over the period.
class Mover {
  const Mover({required this.instrument, required this.changePercent});

  final Instrument instrument;
  final Decimal changePercent;
}

/// How the portfolio did over the last week or month.
class PeriodSummary {
  const PeriodSummary({
    required this.since,
    required this.startValue,
    required this.endValue,
    required this.netInvested,
    this.best,
    this.worst,
  });

  /// Day of the snapshot compared with (may be later than the period start
  /// when the history is shorter).
  final DateTime since;
  final Decimal startValue;
  final Decimal endValue;

  /// Buys minus sells (with a known price) since then.
  final Decimal netInvested;
  final Mover? best;
  final Mover? worst;

  Decimal get change => endValue - startValue;

  /// Change caused by prices, not by buying or selling.
  Decimal get marketEffect => change - netInvested;

  /// [marketEffect] relative to the starting value; `null` without one.
  Decimal? get marketEffectPercent => startValue == Decimal.zero
      ? null
      : (marketEffect * Decimal.fromInt(100) / startValue).toDecimal(
          scaleOnInfinitePrecision: 4,
        );
}

/// Pure calculation from stored snapshots and the current valuation.
abstract final class PeriodSummaryCalculator {
  static final Decimal _hundred = Decimal.fromInt(100);

  /// The snapshot to compare with: the last one on or before the period's
  /// first day, else the oldest one before today. `null` if none.
  static PortfolioSnapshot? baseSnapshot(
    List<PortfolioSnapshot> snapshots,
    SummaryPeriod period,
    DateTime now,
  ) {
    final today = SnapshotBuilder.dayKey(now);
    final start = SnapshotBuilder.dayKey(
      now.subtract(Duration(days: period.days)),
    );
    final before = snapshots.where((s) => s.day.compareTo(today) < 0).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    if (before.isEmpty) return null;
    final onOrBeforeStart = before.where((s) => s.day.compareTo(start) <= 0);
    return onOrBeforeStart.isNotEmpty ? onOrBeforeStart.last : before.first;
  }

  static PeriodSummary? calculate({
    required SummaryPeriod period,
    required DateTime now,
    required List<PortfolioSnapshot> snapshots,
    required List<AssetSnapshot> baseAssets,
    required PortfolioSummary current,
    required List<AssetTransaction> transactions,
  }) {
    final base = baseSnapshot(snapshots, period, now);
    if (base == null || current.totalValue <= Decimal.zero) return null;

    // Transactions after the base day (Istanbul) changed the value too.
    var net = Decimal.zero;
    for (final tx in transactions) {
      final price = tx.unitPriceTry;
      if (price == null) continue;
      if (SnapshotBuilder.dayKey(tx.date).compareTo(base.day) <= 0) continue;
      final amount = tx.quantity * price;
      net += tx.kind == TransactionKind.buy ? amount : -amount;
    }

    final basePrice = {
      for (final a in baseAssets) a.instrument: a.priceTry,
    };
    final movers = <Mover>[
      for (final v in current.holdings)
        if (v.quote case final quote?)
          if (basePrice[quote.instrument] case final from?
              when from > Decimal.zero)
            Mover(
              instrument: quote.instrument,
              changePercent: ((quote.priceTry - from) * _hundred / from)
                  .toDecimal(scaleOnInfinitePrecision: 4),
            ),
    ]..sort((a, b) => b.changePercent.compareTo(a.changePercent));

    return PeriodSummary(
      since: base.date,
      startValue: base.valueTry,
      endValue: current.totalValue,
      netInvested: net,
      best: movers.isEmpty ? null : movers.first,
      worst: movers.length < 2 ? null : movers.last,
    );
  }
}
