import 'package:decimal/decimal.dart';
import 'package:vestra/features/market/data/dto/json_parsing.dart';

/// One item from `/forex`, `/gold` or `/stocks`.
///
/// Field names differ between endpoints and between Bürküt's own docs, so
/// every field is read leniently. Verified against the live API on
/// 2026-11-18 (fixtures in `test/fixtures/burkut/`):
/// - `/forex`: `buyRate`, `sellRate`, `rate`, `currentPrice`,
///   `dailyChangePct`, `updatedAt` (no `buying`/`price`!)
/// - `/gold`: `buying`, `selling`, `price`, `currentPrice`, `dailyChangePct`,
///   `unit`, `updatedAt`
/// - `/stocks`: `price`, `currentPrice`, `changePercent`, `updatedAt`
/// Older names from the SDK (`last_price`, `change_rate`, `time`) are kept
/// as fallbacks. See docs/faz-3-piyasa-verisi.md.
class BurkutPriceDto {
  const BurkutPriceDto({
    required this.symbol,
    required this.price,
    this.name,
    this.changePercent,
    this.updatedAt,
    this.unit,
  });

  /// `null` when the item has no symbol or no usable price.
  static BurkutPriceDto? fromJson(Map<String, dynamic> json) {
    final symbol = json['symbol']?.toString().trim();
    // Buying price first (conservative value for a holding), then the
    // single quoted price, then older SDK names.
    final price = _first(json, positive: true, const [
      'buying',
      'buyRate',
      'price',
      'rate',
      'currentPrice',
      'last_price',
    ]);
    if (symbol == null || symbol.isEmpty || price == null) return null;
    return BurkutPriceDto(
      symbol: symbol.toUpperCase(),
      price: price,
      name: json['name']?.toString(),
      changePercent: _first(json, const [
        'changePercent',
        'dailyChangePct',
        'dailyChangePercent',
        'change_rate',
      ]),
      updatedAt: parseDateTime(json['updatedAt'] ?? json['time']),
      unit: json['unit']?.toString(),
    );
  }

  /// First field among [keys] that parses as a Decimal. With [positive],
  /// zero or negative values are skipped (the live API sends `0` for
  /// fields it doesn't fill, e.g. `close`, `high`).
  static Decimal? _first(
    Map<String, dynamic> json,
    List<String> keys, {
    bool positive = false,
  }) {
    for (final key in keys) {
      final value = parseDecimal(json[key]);
      if (value == null) continue;
      if (positive && value <= Decimal.zero) continue;
      return value;
    }
    return null;
  }

  final String symbol;
  final Decimal price;
  final String? name;

  /// Daily change in percent (`2.44` = +2.44 %).
  final Decimal? changePercent;
  final DateTime? updatedAt;

  /// Only on `/gold`, e.g. `TL/Gr`, `TL/Adet`, `USD/Ons`.
  final String? unit;

  /// False when the provider says the price is not in TRY (e.g. `USD/Ons`).
  bool get isTry {
    final u = unit?.toUpperCase();
    return u == null || u.startsWith('TL') || u.startsWith('TRY');
  }
}

/// Parsed list plus the monthly quota the server reports in
/// `X-Quota-Remaining` / `X-Quota-Limit` (if present).
class BurkutResponse {
  const BurkutResponse(this.items, {this.quotaRemaining, this.quotaLimit});

  final List<BurkutPriceDto> items;
  final int? quotaRemaining;
  final int? quotaLimit;
}
