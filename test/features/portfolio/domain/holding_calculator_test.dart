import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';
import 'package:vestra/features/portfolio/domain/services/holding_calculator.dart';

import '../../../helpers/fixtures.dart';

void main() {
  const buy = TransactionKind.buy;
  const sell = TransactionKind.sell;

  group('HoldingCalculator.calculate', () {
    test('empty history gives zero quantity and zero cost', () {
      final h = HoldingCalculator.calculate(usd, []);

      expect(h.quantity, d('0'));
      expect(h.totalCostTry, d('0'));
      expect(h.averageCostTry, isNull);
      expect(h.isClosed, isTrue);
    });

    test('weighted average over multiple buys', () {
      final h = HoldingCalculator.calculate(usd, [
        tx(id: 1, kind: buy, qty: '100', price: '30'),
        tx(id: 2, kind: buy, qty: '50', price: '36'),
      ]);

      expect(h.quantity, d('150'));
      expect(h.totalCostTry, d('4800'));
      expect(h.averageCostTry, d('32'));
      expect(h.realizedPnlTry, d('0'));
    });

    test('sell reduces cost at average and realizes P/L', () {
      final h = HoldingCalculator.calculate(usd, [
        tx(id: 1, kind: buy, qty: '100', price: '30'),
        tx(id: 2, kind: buy, qty: '50', price: '36'),
        tx(id: 3, kind: sell, qty: '60', price: '40'),
      ]);

      expect(h.quantity, d('90'));
      expect(h.averageCostTry, d('32'));
      expect(h.totalCostTry, d('2880'));
      expect(h.realizedPnlTry, d('480')); // (40 - 32) * 60
    });

    test('processes by date, not by input order', () {
      final h = HoldingCalculator.calculate(usd, [
        tx(id: 2, kind: sell, qty: '10', price: '50', date: DateTime(2026, 3)),
        tx(id: 1, kind: buy, qty: '10', price: '40', date: DateTime(2026)),
      ]);

      expect(h.quantity, d('0'));
      expect(h.realizedPnlTry, d('100'));
    });

    test('fractional quantities stay exact (gram gold)', () {
      final h = HoldingCalculator.calculate(usd, [
        tx(id: 1, kind: buy, qty: '0.1', price: '3000'),
        tx(id: 2, kind: buy, qty: '0.2', price: '3000'),
      ]);

      expect(h.quantity, d('0.3'));
      expect(h.totalCostTry, d('900'));
    });

    test('non-terminating average is rounded to divisionScale', () {
      final h = HoldingCalculator.calculate(usd, [
        tx(id: 1, kind: buy, qty: '1', price: '100'),
        tx(id: 2, kind: buy, qty: '2', price: '0'),
      ]);

      expect(h.totalCostTry, d('100'));
      expect(h.averageCostTry, d('33.3333333333'));
    });

    test('unknown buy price makes cost unknown', () {
      final h = HoldingCalculator.calculate(usd, [
        tx(id: 1, kind: buy, qty: '5'),
        tx(id: 2, kind: buy, qty: '5', price: '10'),
      ]);

      expect(h.quantity, d('10'));
      expect(h.totalCostTry, isNull);
      expect(h.averageCostTry, isNull);
    });

    test('fully closing a position clears unknown cost', () {
      final h = HoldingCalculator.calculate(usd, [
        tx(id: 1, kind: buy, qty: '5'),
        tx(id: 2, kind: sell, qty: '5', price: '10'),
        tx(id: 3, kind: buy, qty: '2', price: '20'),
      ]);

      expect(h.quantity, d('2'));
      expect(h.averageCostTry, d('20'));
      expect(h.realizedPnlTry, isNull);
    });
  });

  group('HoldingCalculator.wouldOversell', () {
    test('false when sells are covered', () {
      expect(
        HoldingCalculator.wouldOversell([
          tx(id: 1, kind: buy, qty: '10'),
          tx(id: 2, kind: sell, qty: '10'),
        ]),
        isFalse,
      );
    });

    test('true when a sell precedes its buy in time', () {
      expect(
        HoldingCalculator.wouldOversell([
          tx(id: 1, kind: buy, qty: '10', date: DateTime(2026, 5)),
          tx(id: 2, kind: sell, qty: '5', date: DateTime(2026, 4)),
        ]),
        isTrue,
      );
    });

    test('true when selling more than held', () {
      expect(
        HoldingCalculator.wouldOversell([
          tx(id: 1, kind: buy, qty: '1.5'),
          tx(id: 2, kind: sell, qty: '1.50001'),
        ]),
        isTrue,
      );
    });
  });
}
