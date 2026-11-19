import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/l10n/failure_messages.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_colors.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/presentation/instrument_labels.dart';
import 'package:vestra/features/portfolio/domain/entities/asset.dart';
import 'package:vestra/features/portfolio/domain/entities/transaction_validation_failure.dart';

String categoryLabel(AppLocalizations l10n, QuoteCategory category) =>
    switch (category) {
      QuoteCategory.fx => l10n.categoryFx,
      QuoteCategory.metals => l10n.marketTabMetals,
      QuoteCategory.stocks => l10n.categoryStocks,
      QuoteCategory.funds => l10n.categoryFunds,
    };

Color categoryColor(QuoteCategory category) => switch (category) {
  QuoteCategory.fx => AppPalette.currency,
  QuoteCategory.metals => AppPalette.gold,
  QuoteCategory.stocks => AppPalette.stock,
  QuoteCategory.funds => AppPalette.fund,
};

/// Display name: localized for known currencies/metals; the ticker for
/// stocks (company names are long; see [assetSubtitle]).
String assetDisplayName(AppLocalizations l10n, Asset asset) =>
    asset.type == AssetType.stock || asset.type == AssetType.fund
    ? asset.code
    : instrumentName(
        l10n,
        (type: asset.type, code: asset.code),
        providerName: asset.name,
      );

/// Company or fund name of a stock/fund, from the stored asset or the
/// latest quote; `null` for other types or when unknown.
String? companyName(Asset asset, Quote? quote) {
  if (asset.type != AssetType.stock && asset.type != AssetType.fund) {
    return null;
  }
  if (asset.name.isNotEmpty && asset.name != asset.code) return asset.name;
  final fromQuote = quote?.name?.trim();
  return fromQuote == null || fromQuote.isEmpty || fromQuote == asset.code
      ? null
      : fromQuote;
}

/// Secondary line on the detail screen: company name for stocks and funds
/// if known, else the market or instrument description.
String assetSubtitle(AppLocalizations l10n, Asset asset, {Quote? quote}) =>
    companyName(asset, quote) ??
    instrumentSubtitle(l10n, (type: asset.type, code: asset.code));

/// Unit shown next to a quantity: ISO code, `gram` or `adet`.
String quantityUnit(AppLocalizations l10n, Instrument instrument) =>
    switch (instrument) {
      (type: AssetType.currency, :final code) => code,
      (type: AssetType.gold, code: 'GRAM') ||
      (type: AssetType.silver, code: _) => l10n.unitGram,
      (type: AssetType.gold || AssetType.stock, code: _) => l10n.unitPiece,
      (type: AssetType.fund, code: _) => l10n.unitShare,
    };

/// `12,5 gram` · `1.250 USD` · `3 adet`.
String formatQuantity(AppLocalizations l10n, Asset asset, Decimal quantity) =>
    '${Formatters.number(quantity, decimals: 6)} '
    '${quantityUnit(l10n, (type: asset.type, code: asset.code))}';

String transactionFailureMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      TransactionValidationFailure(:final reason) => switch (reason) {
        TransactionValidationReason.nonPositiveQuantity => l10n.txErrorQuantity,
        TransactionValidationReason.negativePrice => l10n.txErrorPrice,
        TransactionValidationReason.oversell => l10n.txErrorOversell,
      },
      _ => failureMessage(l10n, failure),
    };
