import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/utils/decimal_input.dart';

import '../helpers/fixtures.dart';

void main() {
  group('parseDecimalInput', () {
    final cases = {
      '12,5': '12.5',
      '1.250,75': '1250.75',
      '12.345.678,9': '12345678.9',
      '1250.75': '1250.75',
      '12.5': '12.5',
      '1.250': '1250',
      '0,0025': '0.0025',
      ' 3 500 ': '3500',
      '100': '100',
      ',5': '0.5',
    };
    for (final MapEntry(key: input, value: expected) in cases.entries) {
      test('"$input" -> $expected', () {
        expect(parseDecimalInput(input), d(expected));
      });
    }

    test('invalid input returns null', () {
      for (final input in ['', '   ', 'abc', '1,2,3', '1..2', '12a']) {
        expect(parseDecimalInput(input), isNull, reason: input);
      }
    });
  });

  test('formatDecimalInput uses a comma and drops trailing zeros', () {
    expect(formatDecimalInput(d('1250.50')), '1250,5');
    expect(formatDecimalInput(d('100')), '100');
    expect(formatDecimalInput(d('0.0025')), '0,0025');
  });

  test('format -> parse round-trips', () {
    for (final v in ['3178.2', '0.123456', '42']) {
      expect(parseDecimalInput(formatDecimalInput(d(v))), d(v));
    }
  });
}
