import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/l10n/l10n.dart';

/// Display name for an instrument: localized for currencies/metals, the
/// ticker for stocks; otherwise the provider's name or the raw code.
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
    (type: AssetType.currency, code: 'AED') => l10n.instrumentAED,
    (type: AssetType.currency, code: 'AZN') => l10n.instrumentAZN,
    (type: AssetType.currency, code: 'CNY') => l10n.instrumentCNY,
    (type: AssetType.currency, code: 'KRW') => l10n.instrumentKRW,
    (type: AssetType.currency, code: 'KWD') => l10n.instrumentKWD,
    (type: AssetType.currency, code: 'KZT') => l10n.instrumentKZT,
    (type: AssetType.currency, code: 'PKR') => l10n.instrumentPKR,
    (type: AssetType.currency, code: 'QAR') => l10n.instrumentQAR,
    (type: AssetType.currency, code: 'RON') => l10n.instrumentRON,
    (type: AssetType.currency, code: 'RUB') => l10n.instrumentRUB,
    (type: AssetType.gold, code: 'GRAM') => l10n.instrumentGoldGram,
    (type: AssetType.gold, code: 'CEYREK') => l10n.instrumentGoldQuarter,
    (type: AssetType.gold, code: 'YARIM') => l10n.instrumentGoldHalf,
    (type: AssetType.gold, code: 'TAM') => l10n.instrumentGoldFull,
    (type: AssetType.gold, code: 'CUMHURIYET') => l10n.instrumentGoldRepublic,
    (type: AssetType.gold, code: 'ATA') => l10n.instrumentGoldAta,
    (type: AssetType.silver, code: 'SILVER_GRAM') => l10n.instrumentSilverGram,
    _ => null,
  };
  // Stocks are shown by ticker; the company name goes in the subtitle.
  if (instrument.type == AssetType.stock || instrument.type == AssetType.fund) {
    return instrument.code;
  }
  return known ?? providerName ?? instrument.code;
}

/// Short label for avatars.
String instrumentShortLabel(Instrument instrument) => switch (instrument) {
  (type: AssetType.gold, code: 'GRAM') => 'GR',
  (type: AssetType.gold, code: 'CEYREK') => '¼',
  (type: AssetType.gold, code: 'YARIM') => '½',
  (type: AssetType.gold, code: 'TAM') => '1',
  (type: AssetType.gold, code: 'CUMHURIYET') => 'CMH',
  (type: AssetType.gold, code: 'ATA') => 'ATA',
  (type: AssetType.silver, code: _) => 'AG',
  _ => instrument.code,
};

/// Sort order inside a section: popular first, then alphabetical.
int instrumentOrder(Instrument instrument) {
  const order = [
    'USD', 'EUR', 'GBP', //
    'GRAM', 'CEYREK', 'YARIM', 'TAM', 'CUMHURIYET', 'ATA', 'SILVER_GRAM',
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
      (type: AssetType.fund, code: _) => l10n.categoryFunds,
    };
