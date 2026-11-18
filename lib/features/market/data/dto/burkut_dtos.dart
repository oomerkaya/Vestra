import 'package:decimal/decimal.dart';
import 'package:vestra/features/market/data/dto/json_parsing.dart';

/// One item from `/forex`, `/gold` or `/stocks`.
///
/// Two sources disagree on field names, so every field is read leniently:
/// - Bürküt AI/REST spec (`price`, `changePercent`, `dailyChangePct`,
///   `updatedAt`, `buying`/`selling` only on `/gold`, `unit`),
/// - official SDK types (`buying`, `selling`, `last_price`, `change_rate`,
///   `time`).
/// Whichever the live API uses, parsing works. See
/// docs/faz-3-piyasa-verisi.md, "Bürküt API spesifikasyonu".
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
    // single quoted price, then the SDK's stock field.
    final price =
        parseDecimal(json['buying']) ??
        parseDecimal(json['price']) ??
        parseDecimal(json['last_price']);
    if (symbol == null || symbol.isEmpty || price == null) return null;
    return BurkutPriceDto(
      symbol: symbol.toUpperCase(),
      price: price,
      name: json['name']?.toString(),
      changePercent:
          parseDecimal(json['changePercent']) ??
          parseDecimal(json['dailyChangePct']) ??
          parseDecimal(json['change_rate']),
      updatedAt: parseDateTime(json['updatedAt'] ?? json['time']),
      unit: json['unit']?.toString(),
    );
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
/// `X-Quota-Remaining` (if present).
class BurkutResponse {
  const BurkutResponse(this.items, {this.quotaRemaining});

  final List<BurkutPriceDto> items;
  final int? quotaRemaining;
}
