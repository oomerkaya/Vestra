import 'package:capira/core/domain/instrument.dart';
import 'package:decimal/decimal.dart';

/// The portfolio's total on one Istanbul day (the day's last known value).
class PortfolioSnapshot {
  const PortfolioSnapshot({
    required this.day,
    required this.valueTry,
    this.costTry,
    this.usdTry,
    this.eurTry,
  });

  /// `YYYY-MM-DD`, Istanbul time.
  final String day;
  final Decimal valueTry;
  final Decimal? costTry;

  /// TRY per USD / EUR that day.
  final Decimal? usdTry;
  final Decimal? eurTry;

  /// [day] as a date (UTC midnight), for charts and comparisons.
  DateTime get date => DateTime.parse('${day}T00:00:00Z');
}

/// One held instrument on one day.
class AssetSnapshot {
  const AssetSnapshot({
    required this.day,
    required this.instrument,
    required this.quantity,
    required this.priceTry,
  });

  final String day;
  final Instrument instrument;
  final Decimal quantity;
  final Decimal priceTry;
}
