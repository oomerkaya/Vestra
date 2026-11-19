import 'package:dio/dio.dart';
import 'package:vestra/features/market/data/dto/burkut_dtos.dart';
import 'package:vestra/features/market/data/dto/json_parsing.dart';
import 'package:vestra/features/market/data/dto/kap_disclosure_dto.dart';

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

  /// All TEFAS funds (2,441 on 2026-11-19, ~1.9 MB). Large JSON is decoded
  /// off the UI thread by dio's default transformer.
  Future<BurkutResponse> getFunds(String apiKey) => _get('/funds', apiKey);

  /// One request. Without [symbols]: the whole BIST market (634 stocks on
  /// 2026-11-18, ~280 KB). With [symbols]: `?symbols=` (honoured by the live
  /// API) and the result is also filtered here as a safeguard.
  Future<BurkutResponse> getStocks(
    String apiKey, {
    List<String>? symbols,
  }) async {
    if (symbols == null) return _get('/stocks', apiKey);
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

  /// Whole BIST market (560+ stocks) in one request; used for the
  /// stock search list, not for prices.
  Future<BurkutResponse> getAllStocks(String apiKey) => _get('/stocks', apiKey);

  /// Latest [size] KAP disclosures of one stock. One request per stock:
  /// `?symbol=A,B` returns nothing (verified 2026-11-19).
  Future<BurkutKapResponse> getKap(
    String apiKey,
    String symbol, {
    int size = 5,
  }) async {
    final response = await _raw(
      '/kap',
      apiKey,
      query: {'symbol': symbol.toUpperCase(), 'size': '$size'},
    );
    return BurkutKapResponse(
      KapDisclosureDto.listFrom(response.data),
      quotaRemaining: _intHeader(response, quotaHeader),
      quotaLimit: _intHeader(response, quotaLimitHeader),
    );
  }

  Future<Response<Object?>> _raw(
    String path,
    String apiKey, {
    Map<String, String>? query,
  }) => _dio.get<Object?>(
    path,
    queryParameters: query,
    options: Options(headers: {'X-API-Key': apiKey}),
  );

  Future<BurkutResponse> _get(
    String path,
    String apiKey, {
    Map<String, String>? query,
  }) async {
    final response = await _raw(path, apiKey, query: query);
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
