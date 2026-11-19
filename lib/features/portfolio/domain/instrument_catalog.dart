import 'package:capira/core/domain/instrument.dart';

/// Instruments a user can pick when adding currencies or metals. Stocks
/// come from the BIST listing instead (see `StockDirectoryRepository`).
abstract final class InstrumentCatalog {
  /// Currencies Bürküt `/forex` serves (verified 2026-11-18, minus XDR),
  /// most common first.
  static const List<String> currencies = [
    'USD', 'EUR', 'GBP', 'CHF', 'JPY', 'CAD', 'AUD', 'SAR', 'AED', 'DKK', //
    'SEK', 'NOK', 'AZN', 'CNY', 'KRW', 'KWD', 'KZT', 'PKR', 'QAR', 'RON',
    'RUB',
  ];

  static const List<Instrument> metals = [
    (type: AssetType.gold, code: 'GRAM'),
    (type: AssetType.gold, code: 'CEYREK'),
    (type: AssetType.gold, code: 'YARIM'),
    (type: AssetType.gold, code: 'TAM'),
    (type: AssetType.gold, code: 'CUMHURIYET'),
    (type: AssetType.gold, code: 'ATA'),
    (type: AssetType.silver, code: 'SILVER_GRAM'),
  ];

  static List<Instrument> get currencyInstruments => [
    for (final c in currencies) (type: AssetType.currency, code: c),
  ];
}
