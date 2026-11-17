import 'dart:async';

import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/utils/app_logger.dart';
import 'package:vestra/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:vestra/features/market/data/datasources/quota_local_data_source.dart';
import 'package:vestra/features/market/data/mappers/quote_mappers.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';
import 'package:vestra/features/market/domain/repositories/market_repository.dart';

/// Orchestrates providers and the local price cache.
///
/// Order per refresh: FX (primary, then fallback on any failure) ->
/// metals -> stocks. If the primary reports a missing/rejected key or an
/// exhausted quota, the remaining primary calls are skipped so no request
/// is wasted.
class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({
    required this._fx,
    required this._fxFallback,
    required this._metals,
    required this._stocks,
    required this._cache,
    required this._quota,
  });

  final FxRateProvider _fx;
  final FxRateProvider _fxFallback;
  final MetalPriceProvider _metals;
  final StockPriceProvider _stocks;
  final PriceCacheLocalDataSource _cache;
  final QuotaLocalDataSource _quota;

  @override
  Stream<Result<List<Quote>>> watchQuotes() => _cache
      .watchAll()
      .map<Result<List<Quote>>>(
        (rows) => Success([for (final row in rows) ?row.toEntity()]),
      )
      .transform(
        StreamTransformer.fromHandlers(
          handleError: (error, stackTrace, sink) {
            AppLogger.error(
              'watchQuotes',
              error: error,
              stackTrace: stackTrace,
            );
            sink.add(Err(StorageFailure(error.toString())));
          },
        ),
      );

  @override
  Future<Result<RefreshReport>> refresh({
    required Set<String> stockSymbols,
  }) async {
    final quotes = <Quote>[];
    final failures = <QuoteCategory, Failure>{};
    var usedFallback = false;
    Failure? primaryBlocked;

    // FX: primary, falling back to the free source on any failure.
    switch (await _fx.fetchRates()) {
      case Success(:final value):
        quotes.addAll(value);
      case Err(:final failure):
        if (_blocksPrimary(failure)) primaryBlocked = failure;
        switch (await _fxFallback.fetchRates()) {
          case Success(:final value):
            quotes.addAll(value);
            usedFallback = true;
          case Err(failure: final fallbackFailure):
            failures[QuoteCategory.fx] = fallbackFailure;
        }
    }

    // Metals.
    if (primaryBlocked != null) {
      failures[QuoteCategory.metals] = primaryBlocked;
    } else {
      switch (await _metals.fetchPrices()) {
        case Success(:final value):
          quotes.addAll(value);
        case Err(:final failure):
          failures[QuoteCategory.metals] = failure;
          if (_blocksPrimary(failure)) primaryBlocked = failure;
      }
    }

    // Stocks (only those in the portfolio, one batched request).
    if (stockSymbols.isNotEmpty) {
      if (primaryBlocked != null) {
        failures[QuoteCategory.stocks] = primaryBlocked;
      } else {
        final symbols = stockSymbols.toList()..sort();
        switch (await _stocks.fetchQuotes(symbols)) {
          case Success(:final value):
            quotes.addAll(value);
          case Err(:final failure):
            failures[QuoteCategory.stocks] = failure;
        }
      }
    }

    try {
      if (quotes.isNotEmpty) {
        await _cache.upsertAll([for (final q in quotes) q.toCompanion()]);
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error('cache write', error: error, stackTrace: stackTrace);
      return Err(StorageFailure(error.toString()));
    }

    return Success(
      RefreshReport(
        updated: quotes.length,
        failures: failures,
        usedFxFallback: usedFallback,
      ),
    );
  }

  @override
  Future<Result<QuotaUsage>> quotaUsage() async {
    try {
      return Success(await _quota.current());
    } on Object catch (error) {
      return Err(StorageFailure(error.toString()));
    }
  }

  static bool _blocksPrimary(Failure f) =>
      f is AuthFailure || f is QuotaExceededFailure;
}
