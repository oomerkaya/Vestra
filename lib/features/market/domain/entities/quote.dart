import 'package:decimal/decimal.dart';
import 'package:vestra/core/domain/instrument.dart';

enum QuoteSource { burkut, frankfurter }

/// Price of one instrument in TRY at a point in time.
///
/// For currencies and metals this is the provider's *buying* price (what a
/// dealer pays you), the conservative value for a portfolio. For stocks it
/// is the last traded price (BIST data is delayed at least 15 minutes).
class Quote {
  const Quote({
    required this.instrument,
    required this.priceTry,
    required this.source,
    required this.fetchedAt,
    this.name,
    this.changePercent,
    this.asOf,
  });

  final Instrument instrument;
  final Decimal priceTry;
  final QuoteSource source;

  /// When the app fetched it.
  final DateTime fetchedAt;

  /// Display name from the provider, if any.
  final String? name;

  /// Daily change in percent (`1.27` means +1.27 %).
  final Decimal? changePercent;

  /// Provider's own timestamp for the price, if given.
  final DateTime? asOf;
}

/// Refresh groups. Each has its own schedule and "last updated" time.
enum QuoteCategory {
  fx,
  metals,
  stocks;

  static QuoteCategory of(AssetType type) => switch (type) {
    AssetType.currency => QuoteCategory.fx,
    AssetType.gold || AssetType.silver => QuoteCategory.metals,
    AssetType.stock => QuoteCategory.stocks,
  };
}
