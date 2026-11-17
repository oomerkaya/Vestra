import 'package:vestra/core/domain/instrument.dart';

/// Maps Bürküt `/gold` symbols to Vestra instruments.
///
/// Verified from the official SDK examples: `ALTIN` (gram gold),
/// `CEYREK_YENI` (quarter coin). The rest follow the same naming pattern and
/// MUST be checked against a live `/gold` response with a real key before
/// release (see docs/faz-3-piyasa-verisi.md, "Doğrulanacaklar").
/// Unknown symbols are ignored.
const Map<String, Instrument> burkutMetalSymbols = {
  'ALTIN': (type: AssetType.gold, code: 'GRAM'),
  'CEYREK_YENI': (type: AssetType.gold, code: 'CEYREK'),
  'YARIM_YENI': (type: AssetType.gold, code: 'YARIM'),
  'TAM_YENI': (type: AssetType.gold, code: 'TAM'),
  'ATA_YENI': (type: AssetType.gold, code: 'CUMHURIYET'),
  'GUMUS': (type: AssetType.silver, code: 'SILVER_GRAM'),
};

final RegExp _currencyCode = RegExp(r'^[A-Z]{3}$');

/// ISO 4217 codes for metals; these come from `/gold`, not as currencies.
const Set<String> _notCurrencies = {'TRY', 'XAU', 'XAG', 'XPT', 'XPD'};

/// `/forex` symbols are ISO 4217 codes (e.g. `USD`); anything else is
/// skipped.
Instrument? burkutForexInstrument(String symbol) =>
    _currencyCode.hasMatch(symbol) && !_notCurrencies.contains(symbol)
    ? (type: AssetType.currency, code: symbol)
    : null;
