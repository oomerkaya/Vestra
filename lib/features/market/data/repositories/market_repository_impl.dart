import 'dart:async';

import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/utils/app_logger.dart';
import 'package:vestra/features/market/data/datasources/market_meta_local_data_source.dart';
import 'package:vestra/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:vestra/features/market/data/datasources/quota_local_data_source.dart';
import 'package:vestra/features/market/data/mappers/burkut_symbols.dart';
import 'package:vestra/features/market/data/mappers/quote_mappers.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';
import 'package:vestra/features/market/domain/repositories/market_repository.dart';

/// Orchestrates providers and the local price cache.
///
/// Only the requested categories are fetched. Order: FX (primary, then
/// fallback on any failure) -> metals -> stocks. If the primary reports a missing/rejected key or an
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
    required this._meta,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final FxRateProvider _fx;
  final FxRateProvider _fxFallback;
  final MetalPriceProvider _metals;
  final StockPriceProvider _stocks;
  final PriceCacheLocalDataSource _cache;
  final QuotaLocalDataSource _quota;
  final MarketMetaLocalDataSource _meta;
  final DateTime Function() _clock;

  @override
  Stream<Result<List<Quote>>> watchQuotes() => _cache
      .watchAll()
      .map<Result<List<Quote>>>(
        (rows) => Success([
          for (final row in rows)
            if (row.toEntity() case final q? when _isSupported(q)) q,
        ]),
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
    required Set<QuoteCategory> categories,
    Set<String>? stockSymbols,
  }) async {
    final quotes = <Quote>[];
    final failures = <QuoteCategory, Failure>{};
    var usedFallback = false;
    Failure? primaryBlocked;
    var wholeMarket = false;
    // Categories fetched as the provider's complete list (not the partial
    // free FX fallback): their stale rows are replaced, not kept.
    final complete = <QuoteCategory>{};

    // FX: primary, falling back to the free source on any failure.
    if (categories.contains(QuoteCategory.fx)) {
      switch (await _fx.fetchRates()) {
        case Success(:final value):
          quotes.addAll(value);
          complete.add(QuoteCategory.fx);
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
    }

    // Metals.
    if (!categories.contains(QuoteCategory.metals)) {
      // not requested
    } else if (primaryBlocked != null) {
      failures[QuoteCategory.metals] = primaryBlocked;
    } else {
      switch (await _metals.fetchPrices()) {
        case Success(:final value):
          quotes.addAll(value);
          complete.add(QuoteCategory.metals);
        case Err(:final failure):
          failures[QuoteCategory.metals] = failure;
          if (_blocksPrimary(failure)) primaryBlocked = failure;
      }
    }

    // Stocks: whole market or the given symbols, one request either way.
    if (categories.contains(QuoteCategory.stocks) &&
        (stockSymbols == null || stockSymbols.isNotEmpty)) {
      if (primaryBlocked != null) {
        failures[QuoteCategory.stocks] = primaryBlocked;
      } else {
        final symbols = stockSymbols?.toList()?..sort();
        switch (await _stocks.fetchQuotes(symbols: symbols)) {
          case Success(:final value):
            quotes.addAll(value);
            if (symbols == null && value.isNotEmpty) {
              wholeMarket = true;
              complete.add(QuoteCategory.stocks);
            }
          case Err(:final failure):
            failures[QuoteCategory.stocks] = failure;
        }
      }
    }

    try {
      if (quotes.isNotEmpty) {
        await _cache.upsertAll([for (final q in quotes) q.toCompanion()]);
      }
      await _dropStale(complete, quotes);
      if (wholeMarket) await _meta.setStocksSnapshotAt(_clock());
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

  /// For each complete category with a non-empty result, deletes cached
  /// rows the provider no longer lists.
  Future<void> _dropStale(
    Set<QuoteCategory> complete,
    List<Quote> quotes,
  ) async {
    for (final category in complete) {
      final fetched = [
        for (final q in quotes)
          if (QuoteCategory.of(q.instrument.type) == category) q,
      ];
      if (fetched.isEmpty) continue; // never wipe on an empty answer
      await _cache.deleteMissing(
        {
          for (final t in AssetType.values)
            if (QuoteCategory.of(t) == category) t.name,
        },
        {for (final q in fetched) q.instrument.code},
      );
    }
  }

  /// Metals are limited to the instruments the app supports, so rows left
  /// from older versions (e.g. ounce gold) are not shown.
  static bool _isSupported(Quote q) =>
      QuoteCategory.of(q.instrument.type) != QuoteCategory.metals ||
      _supportedMetals.contains(q.instrument);

  static final Set<Instrument> _supportedMetals = {
    ...burkutMetalSymbols.values,
  };

  @override
  Future<DateTime?> stocksSnapshotAt() async {
    try {
      return await _meta.stocksSnapshotAt();
    } on Object {
      return null;
    }
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
