import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:vestra/features/market/data/dto/json_parsing.dart';

/// ECB reference rates via Frankfurter. Free, no key, updated once per
/// working day (around 16:00 CET). Does NOT provide gold or silver.
class FrankfurterRemoteDataSource {
  FrankfurterRemoteDataSource(this._dio);

  static const String baseUrl = 'https://api.frankfurter.dev/v1';

  final Dio _dio;

  /// Returns how many units of each currency one TRY buys, plus the ECB
  /// reference date. Throws [DioException].
  Future<({DateTime? date, Map<String, Decimal> perTry})> latestPerTry(
    List<String> symbols,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/latest',
      queryParameters: {'base': 'TRY', 'symbols': symbols.join(',')},
    );
    final body = response.data ?? const <String, dynamic>{};
    final rates = body['rates'];
    return (
      date: parseDateTime(body['date']),
      perTry: {
        if (rates is Map<String, dynamic>)
          for (final entry in rates.entries)
            entry.key.toUpperCase(): ?parseDecimal(entry.value),
      },
    );
  }
}
