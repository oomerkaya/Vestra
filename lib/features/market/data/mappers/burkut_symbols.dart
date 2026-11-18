import 'package:vestra/core/domain/instrument.dart';

/// Maps Bürküt `/gold` symbols to Vestra instruments.
///
/// Canonical codes from Bürküt's REST spec: `ALTIN` (gram), `CEYREK_YENI`,
/// `YARIM`, `TAM`, `CUMHURIYET`, `ATA`, `GUMTRY` (gram silver, TRY).
/// The spec also lists aliases the server accepts (`GRAM_ALTIN`, `GAU`,
/// `CEYREK`, `GUMUS`); they are mapped too in case a response uses them.
///
/// Deliberately not mapped: `XAUUSD` (priced in USD), `PLATIN`,
/// `PALADYUM` (out of scope for now). Unknown symbols are ignored.
const Map<String, Instrument> burkutMetalSymbols = {
  'ALTIN': (type: AssetType.gold, code: 'GRAM'),
  'GRAM_ALTIN': (type: AssetType.gold, code: 'GRAM'),
  'GAU': (type: AssetType.gold, code: 'GRAM'),
  'CEYREK_YENI': (type: AssetType.gold, code: 'CEYREK'),
  'CEYREK': (type: AssetType.gold, code: 'CEYREK'),
  'YARIM': (type: AssetType.gold, code: 'YARIM'),
  'TAM': (type: AssetType.gold, code: 'TAM'),
  'CUMHURIYET': (type: AssetType.gold, code: 'CUMHURIYET'),
  'ATA': (type: AssetType.gold, code: 'ATA'),
  'GUMTRY': (type: AssetType.silver, code: 'SILVER_GRAM'),
  'GUMUS': (type: AssetType.silver, code: 'SILVER_GRAM'),
};

final RegExp _currencyCode = RegExp(r'^[A-Z]{3}$');

/// ISO 4217 codes for metals; these come from `/gold`, not as currencies.
const Set<String> _notCurrencies = {'TRY', 'XAU', 'XAG', 'XPT', 'XPD'};

/// `/forex` symbols are ISO 4217 codes (e.g. `USD`). The spec says
/// `USDTRY` / `USD/TRY` are accepted as input, so those forms are
/// normalised too. Anything else is skipped.
Instrument? burkutForexInstrument(String symbol) {
  var code = symbol.toUpperCase().replaceAll('/', '');
  if (code.length == 6 && code.endsWith('TRY')) code = code.substring(0, 3);
  return _currencyCode.hasMatch(code) && !_notCurrencies.contains(code)
      ? (type: AssetType.currency, code: code)
      : null;
}
