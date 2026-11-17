import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/l10n/l10n.dart';

/// Display name for an instrument; falls back to the provider's name and
/// finally to the raw code.
String instrumentName(
  AppLocalizations l10n,
  Instrument instrument, {
  String? providerName,
}) {
  final known = switch (instrument) {
    (type: AssetType.currency, code: 'USD') => l10n.instrumentUSD,
    (type: AssetType.currency, code: 'EUR') => l10n.instrumentEUR,
    (type: AssetType.currency, code: 'GBP') => l10n.instrumentGBP,
    (type: AssetType.currency, code: 'CHF') => l10n.instrumentCHF,
    (type: AssetType.currency, code: 'JPY') => l10n.instrumentJPY,
    (type: AssetType.currency, code: 'CAD') => l10n.instrumentCAD,
    (type: AssetType.currency, code: 'AUD') => l10n.instrumentAUD,
    (type: AssetType.currency, code: 'DKK') => l10n.instrumentDKK,
    (type: AssetType.currency, code: 'SEK') => l10n.instrumentSEK,
    (type: AssetType.currency, code: 'NOK') => l10n.instrumentNOK,
    (type: AssetType.currency, code: 'SAR') => l10n.instrumentSAR,
    (type: AssetType.gold, code: 'GRAM') => l10n.instrumentGoldGram,
    (type: AssetType.gold, code: 'CEYREK') => l10n.instrumentGoldQuarter,
    (type: AssetType.gold, code: 'YARIM') => l10n.instrumentGoldHalf,
    (type: AssetType.gold, code: 'TAM') => l10n.instrumentGoldFull,
    (type: AssetType.gold, code: 'CUMHURIYET') => l10n.instrumentGoldRepublic,
    (type: AssetType.silver, code: 'SILVER_GRAM') => l10n.instrumentSilverGram,
    _ => null,
  };
  return known ?? providerName ?? instrument.code;
}

/// Short label for avatars.
String instrumentShortLabel(Instrument instrument) => switch (instrument) {
  (type: AssetType.gold, code: 'GRAM') => 'GR',
  (type: AssetType.gold, code: 'CEYREK') => '¼',
  (type: AssetType.gold, code: 'YARIM') => '½',
  (type: AssetType.gold, code: 'TAM') => '1',
  (type: AssetType.gold, code: 'CUMHURIYET') => 'CMH',
  (type: AssetType.silver, code: _) => 'AG',
  _ => instrument.code,
};

/// Sort order inside a section: popular first, then alphabetical.
int instrumentOrder(Instrument instrument) {
  const order = [
    'USD', 'EUR', 'GBP', //
    'GRAM', 'CEYREK', 'YARIM', 'TAM', 'CUMHURIYET', 'SILVER_GRAM',
  ];
  final index = order.indexOf(instrument.code);
  return index == -1 ? order.length : index;
}

/// Secondary line under the name: ISO code for currencies, unit for
/// metals, exchange for stocks.
String instrumentSubtitle(AppLocalizations l10n, Instrument instrument) =>
    switch (instrument) {
      (type: AssetType.currency, :final code) => code,
      (type: AssetType.gold || AssetType.silver, code: 'GRAM') ||
      (type: AssetType.silver, code: 'SILVER_GRAM') => l10n.unitGram,
      (type: AssetType.gold || AssetType.silver, code: _) => l10n.unitPiece,
      (type: AssetType.stock, code: _) => l10n.exchangeBist,
    };
