import 'package:decimal/decimal.dart';
import 'package:vestra/features/market/data/dto/json_parsing.dart';

/// `/forex` and `/gold` item. Field names from the official SDK
/// (github.com/sametakan29/burkut-sdks, `nodejs/src/types.ts`).
class BurkutRateDto {
  const BurkutRateDto({
    required this.symbol,
    required this.buying,
    this.selling,
    this.name,
    this.changeRate,
    this.time,
  });

  static BurkutRateDto? fromJson(Map<String, dynamic> json) {
    final symbol = json['symbol']?.toString();
    final buying = parseDecimal(json['buying']);
    if (symbol == null || buying == null) return null;
    return BurkutRateDto(
      symbol: symbol.toUpperCase(),
      buying: buying,
      selling: parseDecimal(json['selling']),
      name: json['name']?.toString(),
      changeRate: parseDecimal(json['change_rate']),
      time: parseDateTime(json['time']),
    );
  }

  final String symbol;
  final Decimal buying;
  final Decimal? selling;
  final String? name;
  final Decimal? changeRate;
  final DateTime? time;
}

/// `/stocks` item.
class BurkutStockDto {
  const BurkutStockDto({
    required this.symbol,
    required this.lastPrice,
    this.name,
    this.changeRate,
    this.time,
  });

  static BurkutStockDto? fromJson(Map<String, dynamic> json) {
    final symbol = json['symbol']?.toString();
    final price = parseDecimal(json['last_price']);
    if (symbol == null || price == null) return null;
    return BurkutStockDto(
      symbol: symbol.toUpperCase(),
      lastPrice: price,
      name: json['name']?.toString(),
      changeRate: parseDecimal(json['change_rate']),
      time: parseDateTime(json['time']),
    );
  }

  final String symbol;
  final Decimal lastPrice;
  final String? name;
  final Decimal? changeRate;
  final DateTime? time;
}
