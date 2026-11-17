import 'package:dio/dio.dart';
import 'package:vestra/features/market/data/dto/burkut_dtos.dart';
import 'package:vestra/features/market/data/dto/json_parsing.dart';

/// Raw HTTP access to the Bürküt public API. Throws [DioException].
///
/// Endpoints and auth taken from the official SDK source
/// (`DEFAULT_BASE_URL`, `X-API-Key` header). Every call costs one request
/// from the user's monthly quota.
class BurkutRemoteDataSource {
  BurkutRemoteDataSource(this._dio);

  static const String baseUrl = 'https://api.burkutportfoy.com/api/public/v1';

  final Dio _dio;

  Future<List<BurkutRateDto>> getForex(String apiKey) async =>
      _rates(await _get('/forex', apiKey));

  Future<List<BurkutRateDto>> getGold(String apiKey) async =>
      _rates(await _get('/gold', apiKey));

  /// All [symbols] in a single request (`?symbols=A,B,C`).
  Future<List<BurkutStockDto>> getStocks(
    String apiKey,
    List<String> symbols,
  ) async {
    final data = await _get(
      '/stocks',
      apiKey,
      query: {'symbols': symbols.map((s) => s.toUpperCase()).join(',')},
    );
    return [
      for (final json in unwrapList(data)) ?BurkutStockDto.fromJson(json),
    ];
  }

  Future<Object?> _get(
    String path,
    String apiKey, {
    Map<String, String>? query,
  }) async {
    final response = await _dio.get<Object?>(
      path,
      queryParameters: query,
      options: Options(headers: {'X-API-Key': apiKey}),
    );
    return response.data;
  }

  List<BurkutRateDto> _rates(Object? data) => [
    for (final json in unwrapList(data)) ?BurkutRateDto.fromJson(json),
  ];
}
