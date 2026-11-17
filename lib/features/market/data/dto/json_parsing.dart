import 'package:decimal/decimal.dart';

/// Lenient helpers for third-party JSON. Numbers may arrive as `num` or
/// `String`; anything unparseable becomes `null` instead of throwing.

Decimal? parseDecimal(Object? value) {
  if (value == null) return null;
  if (value is int) return Decimal.fromInt(value);
  final text = value.toString().trim().replaceAll(',', '.');
  if (text.isEmpty) return null;
  return Decimal.tryParse(text);
}

DateTime? parseDateTime(Object? value) {
  if (value == null) return null;
  if (value is int) {
    // Unix seconds vs. milliseconds.
    return DateTime.fromMillisecondsSinceEpoch(
      value < 100000000000 ? value * 1000 : value,
      isUtc: true,
    );
  }
  return DateTime.tryParse(value.toString());
}

/// Accepts either a bare list or `{ "data": [...] }`.
List<Map<String, dynamic>> unwrapList(Object? payload) {
  final raw = payload is Map<String, dynamic> ? payload['data'] : payload;
  if (raw is! List) return const [];
  return [
    for (final item in raw)
      if (item is Map<String, dynamic>) item,
  ];
}
