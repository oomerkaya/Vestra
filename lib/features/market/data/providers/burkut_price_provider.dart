import 'package:dio/dio.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/network/dio_failure_mapper.dart';
import 'package:vestra/core/utils/app_logger.dart';
import 'package:vestra/features/market/data/datasources/burkut_remote_data_source.dart';
import 'package:vestra/features/market/data/datasources/quota_local_data_source.dart';
import 'package:vestra/features/market/data/dto/burkut_dtos.dart';
import 'package:vestra/features/market/data/mappers/burkut_symbols.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/entities/stock_listing.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';
import 'package:vestra/features/settings/domain/repositories/api_key_repository.dart';

/// Bürküt implementation of all three price interfaces.
///
/// Before each request: needs an API key (else `AuthFailure(missingKey)`)
/// and remaining quota (else `QuotaExceededFailure`); no request is sent in
/// either case. Every sent request is counted, and the local counter is
/// synced to the server's `X-Quota-Remaining` whenever it is reported.
class BurkutPriceProvider
    implements
        FxRateProvider,
        MetalPriceProvider,
        StockPriceProvider,
        StockListingProvider,
        ApiKeyValidator {
  BurkutPriceProvider({
    required this._remote,
    required this._readApiKey,
    required this._quota,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final BurkutRemoteDataSource _remote;
  final Future<String?> Function() _readApiKey;
  final QuotaLocalDataSource _quota;
  final DateTime Function() _clock;

  @override
  Future<Result<List<Quote>>> fetchRates() => _call(
    'forex',
    (key) async => [
      for (final dto in await _items(_remote.getForex(key)))
        if (burkutForexInstrument(dto.symbol) case final instrument?)
          _quote(instrument, dto),
    ],
  );

  @override
  Future<Result<List<Quote>>> fetchPrices() => _call(
    'gold',
    (key) async => [
      for (final dto in await _items(_remote.getGold(key)))
        if (dto.isTry)
          if (burkutMetalSymbols[dto.symbol] case final instrument?)
            _quote(instrument, dto),
    ],
  );

  @override
  Future<Result<List<Quote>>> fetchQuotes({List<String>? symbols}) {
    if (symbols != null && symbols.isEmpty) {
      return Future.value(const Success(<Quote>[]));
    }
    return _call(
      'stocks',
      (key) async => [
        for (final dto in await _items(
          _remote.getStocks(key, symbols: symbols),
        ))
          _quote((type: AssetType.stock, code: dto.symbol), dto),
      ],
    );
  }

  @override
  Future<Result<List<StockListing>>> fetchListings() => _call(
    'stock list',
    (key) async => [
      for (final dto in await _items(_remote.getAllStocks(key)))
        StockListing(symbol: dto.symbol, name: dto.name ?? dto.symbol),
    ],
  );

  /// Validates a key with one cheap request (counts against the quota).
  @override
  Future<Result<void>> validate(String key) async {
    final usage = await _quota.current();
    if (usage.isExhausted) return const Err(QuotaExceededFailure());
    await _quota.recordRequest();
    try {
      await _items(_remote.getForex(key));
      return const Success(null);
    } on DioException catch (e) {
      return Err(await _handle(e));
    }
  }

  Future<Result<T>> _call<T>(
    String what,
    Future<T> Function(String key) body,
  ) async {
    final key = await _readApiKey();
    if (key == null || key.isEmpty) {
      return const Err(AuthFailure(missingKey: true));
    }
    final usage = await _quota.current();
    if (usage.isExhausted) return const Err(QuotaExceededFailure());

    await _quota.recordRequest();
    try {
      return Success(await body(key));
    } on DioException catch (e) {
      return Err(await _handle(e));
    } on Object catch (e, st) {
      AppLogger.error('burkut $what parse failed', error: e, stackTrace: st);
      return Err(UnexpectedFailure('burkut $what: ${e.runtimeType}'));
    }
  }

  Future<Failure> _handle(DioException e) async {
    final failure = mapDioException(e);
    AppLogger.warning('burkut request failed: ${failure.runtimeType}');
    if (failure is QuotaExceededFailure) await _quota.markExhausted();
    return failure;
  }

  /// Unwraps a response and syncs the quota counter if the server
  /// reported the remaining monthly requests.
  Future<List<BurkutPriceDto>> _items(Future<BurkutResponse> call) async {
    final response = await call;
    final remaining = response.quotaRemaining;
    if (remaining != null) {
      await _quota.syncRemaining(remaining, limit: response.quotaLimit);
    }
    return response.items;
  }

  Quote _quote(Instrument instrument, BurkutPriceDto dto) => Quote(
    instrument: instrument,
    priceTry: dto.price,
    source: QuoteSource.burkut,
    fetchedAt: _clock(),
    name: dto.name,
    changePercent: dto.changePercent,
    asOf: dto.updatedAt,
  );
}
