import 'package:capira/core/domain/instrument.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/holding.dart';
import 'package:capira/features/portfolio/domain/services/portfolio_valuator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

Holding _holding(
  int id,
  AssetType type,
  String code,
  String qty, {
  String? cost,
}) => Holding(
  asset: Asset(id: id, type: type, code: code, name: code),
  quantity: d(qty),
  transactionCount: 1,
  totalCostTry: cost == null ? null : d(cost),
);

Quote _quote(AssetType type, String code, String price, {String? change}) =>
    Quote(
      instrument: (type: type, code: code),
      priceTry: d(price),
      source: QuoteSource.burkut,
      fetchedAt: DateTime(2026, 11, 18),
      changePercent: change == null ? null : d(change),
    );

void main() {
  test('values holdings, totals and allocation per category', () {
    final summary = PortfolioValuator.value(
      [
        _holding(1, AssetType.currency, 'USD', '100', cost: '4000'),
        _holding(2, AssetType.gold, 'GRAM', '10', cost: '50000'),
        _holding(3, AssetType.stock, 'THYAO', '20', cost: '6000'),
      ],
      [
        _quote(AssetType.currency, 'USD', '42'),
        _quote(AssetType.gold, 'GRAM', '6000'),
        _quote(AssetType.stock, 'THYAO', '320'),
      ],
    );

    expect(summary.totalValue, d('70600')); // 4200 + 60000 + 6400
    expect(summary.totalCost, d('60000'));
    expect(summary.unrealizedPnl, d('10600'));
    expect(summary.unrealizedPnlPercent!.round(scale: 4), d('17.6667'));
    expect(summary.valueByCategory, {
      QuoteCategory.fx: d('4200'),
      QuoteCategory.metals: d('60000'),
      QuoteCategory.stocks: d('6400'),
    });
    expect(
      summary.holdings.map((h) => h.holding.asset.code),
      ['GRAM', 'THYAO', 'USD'],
      reason: 'highest value first',
    );
  });

  test('holdings without a price are listed last and excluded', () {
    final summary = PortfolioValuator.value(
      [
        _holding(1, AssetType.currency, 'USD', '100', cost: '4000'),
        _holding(2, AssetType.gold, 'ATA', '1', cost: '40000'),
      ],
      [_quote(AssetType.currency, 'USD', '42')],
    );

    expect(summary.totalValue, d('4200'));
    expect(summary.totalCost, d('4000'), reason: 'unpriced cost excluded');
    expect(summary.missingPriceCount, 1);
    expect(summary.holdings.last.hasPrice, isFalse);
  });

  test('unknown cost: value counted, P/L left out', () {
    final summary = PortfolioValuator.value(
      [
        _holding(1, AssetType.gold, 'GRAM', '5'),
        _holding(2, AssetType.currency, 'USD', '10', cost: '400'),
      ],
      [
        _quote(AssetType.gold, 'GRAM', '6000'),
        _quote(AssetType.currency, 'USD', '42'),
      ],
    );

    expect(summary.totalValue, d('30420'));
    expect(summary.unrealizedPnl, d('20'));
    final gram = summary.holdings.firstWhere(
      (h) => h.holding.asset.code == 'GRAM',
    );
    expect(gram.unrealizedPnl, isNull);
  });

  test('daily change from the quote percentage', () {
    final summary = PortfolioValuator.value(
      [_holding(1, AssetType.stock, 'THYAO', '10', cost: '3000')],
      // +25 % today: previous close 400 -> now 500
      [_quote(AssetType.stock, 'THYAO', '500', change: '25')],
    );

    expect(summary.dailyChange, d('1000'));
    expect(summary.dailyChangePercent, d('25'));
  });

  test('closed positions are not shown', () {
    final summary = PortfolioValuator.value(
      [_holding(1, AssetType.currency, 'USD', '0', cost: '0')],
      [_quote(AssetType.currency, 'USD', '42')],
    );

    expect(summary.isEmpty, isTrue);
    expect(summary.totalValue, d('0'));
  });
}
