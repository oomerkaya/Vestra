import 'package:decimal/decimal.dart';

/// Turkish number formatting done on [Decimal] directly (no `double`), so
/// displayed values are exactly the rounded stored values.
///
/// Conventions: thousands `.`, decimals `,`, currency `₺` prefix,
/// percent `%` prefix (e.g. `₺248.320,45`, `%1,27`).
abstract final class Formatters {
  static const String _minus = '−'; // U+2212, typographic minus

  /// `₺1.234,50`. Negative values: `−₺1.234,50`.
  static String currencyTry(Decimal value, {int decimals = 2}) {
    final body = number(value.abs(), decimals: decimals, trimZeros: false);
    return value < Decimal.zero ? '$_minus₺$body' : '₺$body';
  }

  /// Signed amount for changes: `+₺120,00` / `−₺35,10` / `₺0,00`.
  static String signedCurrencyTry(Decimal value, {int decimals = 2}) {
    final rounded = value.round(scale: decimals);
    if (rounded == Decimal.zero) return currencyTry(Decimal.zero);
    final body = number(rounded.abs(), decimals: decimals, trimZeros: false);
    return rounded > Decimal.zero ? '+₺$body' : '$_minus₺$body';
  }

  /// `%1,27` / `+%1,27` with [signed].
  static String percent(
    Decimal value, {
    int decimals = 2,
    bool signed = false,
  }) {
    final rounded = value.round(scale: decimals);
    final body = number(rounded.abs(), decimals: decimals, trimZeros: false);
    if (rounded == Decimal.zero) return '%$body';
    if (rounded < Decimal.zero) return '$_minus%$body';
    return signed ? '+%$body' : '%$body';
  }

  /// Plain number with Turkish separators.
  ///
  /// With [trimZeros] trailing fractional zeros are removed
  /// (quantities: `42,5` instead of `42,50`, `1.250` instead of `1.250,00`).
  static String number(
    Decimal value, {
    int decimals = 2,
    bool trimZeros = true,
  }) {
    final negative = value < Decimal.zero;
    final fixed = value.abs().round(scale: decimals).toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = _groupThousands(parts[0]);
    var frac = parts.length > 1 ? parts[1] : '';
    if (trimZeros) frac = frac.replaceFirst(RegExp(r'0+$'), '');
    final sign = negative && (intPart != '0' || frac.isNotEmpty) ? _minus : '';
    return frac.isEmpty ? '$sign$intPart' : '$sign$intPart,$frac';
  }

  static String _groupThousands(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
