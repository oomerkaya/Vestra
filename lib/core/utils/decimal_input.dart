import 'package:decimal/decimal.dart';

/// Parses numbers typed by Turkish users into [Decimal].
///
/// Accepted: `12,5` · `1.250,75` · `1250.75` · `0,0025` · ` 3 500 `.
/// Rules:
/// - Spaces are ignored.
/// - If a comma is present, it is the decimal separator and dots are
///   thousands separators (Turkish convention).
/// - With only dots: `1.250` / `12.345.678` (groups of exactly three
///   digits) are thousands; anything else (`12.5`) is a decimal point.
/// Returns `null` for empty or invalid input.
Decimal? parseDecimalInput(String input) {
  var text = input.replaceAll(RegExp(r'\s'), '');
  if (text.isEmpty) return null;
  final negative = text.startsWith('-');
  if (negative) text = text.substring(1);

  if (text.contains(',')) {
    if (','.allMatches(text).length > 1) return null;
    text = text.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(text)) {
    text = text.replaceAll('.', '');
  }
  if (!RegExp(r'^(\d+(\.\d*)?|\.\d+)$').hasMatch(text)) return null;
  final value = Decimal.tryParse(text);
  if (value == null) return null;
  return negative ? -value : value;
}

/// Formats a [Decimal] for an input field: Turkish comma, no thousands
/// separators, no trailing zeros (`1250.50` → `1250,5`).
String formatDecimalInput(Decimal value) {
  var text = value.toString();
  if (text.contains('.')) {
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  return text.replaceAll('.', ',');
}
