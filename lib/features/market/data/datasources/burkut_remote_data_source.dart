import 'package:dio/dio.dart';
import 'package:vestra/features/market/data/dto/burkut_dtos.dart';
import 'package:vestra/features/market/data/dto/json_parsing.dart';

/// Raw HTTP access to the Bürküt public API. Throws [DioException].
///
/// Base URL and `X-API-Key` auth from the official SDK and Bürküt's REST
/// spec. Every call costs one request from the monthly quota (free plan:
/// 1,000/month, 10/minute).
class BurkutRemoteDataSource {
  BurkutRemoteDataSource(this._dio);

  static const String baseUrl = 'https://api.burkutportfoy.com/api/public/v1';
  static const String quotaHeader = 'x-quota-remaining';
  static const String quotaLimitHeader = 'x-quota-limit';

  final Dio _dio;

  Future<BurkutResponse> getForex(String apiKey) => _get('/forex', apiKey);

  Future<BurkutResponse> getGold(String apiKey) => _get('/gold', apiKey);

  /// One request for all [symbols]. The live API honours `?symbols=`
  /// (verified 2026-11-18); without it `/stocks` returns the whole market
  /// (560+ stocks), so the result is also filtered here as a safeguard.
  Future<BurkutResponse> getStocks(String apiKey, List<String> symbols) async {
    final wanted = {for (final s in symbols) s.toUpperCase()};
    final response = await _get(
      '/stocks',
      apiKey,
      query: {'symbols': wanted.join(',')},
    );
    return BurkutResponse(
      [
        for (final dto in response.items)
          if (wanted.contains(dto.symbol)) dto,
      ],
      quotaRemaining: response.quotaRemaining,
      quotaLimit: response.quotaLimit,
    );
  }

  Future<BurkutResponse> _get(
    String path,
    String apiKey, {
    Map<String, String>? query,
  }) async {
    final response = await _dio.get<Object?>(
      path,
      queryParameters: query,
      options: Options(headers: {'X-API-Key': apiKey}),
    );
    return BurkutResponse(
      [
        for (final json in unwrapList(response.data))
          ?BurkutPriceDto.fromJson(json),
      ],
      quotaRemaining: _intHeader(response, quotaHeader),
      quotaLimit: _intHeader(response, quotaLimitHeader),
    );
  }

  static int? _intHeader(Response<Object?> response, String name) =>
      int.tryParse(response.headers.value(name)?.trim() ?? '');
}
