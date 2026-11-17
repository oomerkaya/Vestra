import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/utils/formatters.dart';

import '../helpers/fixtures.dart';

void main() {
  group('Formatters.currencyTry', () {
    test('groups thousands and uses comma decimals', () {
      expect(Formatters.currencyTry(d('248320.45')), '₺248.320,45');
      expect(Formatters.currencyTry(d('0')), '₺0,00');
      expect(Formatters.currencyTry(d('999')), '₺999,00');
      expect(Formatters.currencyTry(d('1000')), '₺1.000,00');
      expect(Formatters.currencyTry(d('1234567.891')), '₺1.234.567,89');
    });

    test('negative values get a typographic minus', () {
      expect(Formatters.currencyTry(d('-35.1')), '−₺35,10');
    });

    test('rounds half away from zero', () {
      expect(Formatters.currencyTry(d('0.005')), '₺0,01');
      expect(Formatters.currencyTry(d('0.004')), '₺0,00');
    });
  });

  test('signedCurrencyTry', () {
    expect(Formatters.signedCurrencyTry(d('3120')), '+₺3.120,00');
    expect(Formatters.signedCurrencyTry(d('-1.5')), '−₺1,50');
    expect(Formatters.signedCurrencyTry(d('0.001')), '₺0,00');
  });

  test('percent', () {
    expect(Formatters.percent(d('1.2649')), '%1,26');
    expect(Formatters.percent(d('1.27'), signed: true), '+%1,27');
    expect(Formatters.percent(d('-0.5')), '−%0,50');
    expect(Formatters.percent(d('0')), '%0,00');
  });

  group('Formatters.number', () {
    test('trims trailing zeros for quantities', () {
      expect(Formatters.number(d('42.50')), '42,5');
      expect(Formatters.number(d('1250')), '1.250');
      expect(Formatters.number(d('0.1234'), decimals: 4), '0,1234');
    });

    test('keeps zeros when asked', () {
      expect(Formatters.number(d('42.5'), trimZeros: false), '42,50');
    });

    test('negative rounding to zero has no sign', () {
      expect(Formatters.number(d('-0.001')), '0');
    });
  });
}
