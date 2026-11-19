import 'dart:async';

import 'package:capira/core/domain/instrument.dart';
import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/core/utils/app_logger.dart';
import 'package:capira/features/market/data/datasources/market_meta_local_data_source.dart';
import 'package:capira/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:capira/features/market/data/datasources/quota_local_data_source.dart';
import 'package:capira/features/market/data/mappers/burkut_symbols.dart';
import 'package:capira/features/market/data/mappers/quote_mappers.dart';
import 'package:capira/features/market/domain/entities/quota_usage.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/domain/providers/price_providers.dart';
import 'package:capira/features/market/domain/repositories/market_repository.dart';

/// Orchestrates providers and the local price cache.
///
/// Only the requested categories are fetched, all from Bürküt. Order:
/// FX -> metals -> stocks -> funds. If the primary reports a missing/rejected key or an
/// exhausted quota, the remaining primary calls are skipped so no request
/// is wasted.
class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({
    required this._fx,
    required this._metals,
    required this._stocks,
    required this._funds,
    required this._cache,
    required this._quota,
    required this._meta,
    this._quotaStatus,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final FxRateProvider _fx;
  final MetalPriceProvider _metals;
  final StockPriceProvider _stocks;
  final FundPriceProvider _funds;
  final PriceCacheLocalDataSource _cache;
  final QuotaLocalDataSource _quota;
  final MarketMetaLocalDataSource _meta;
  final QuotaStatusProvider? _quotaStatus;
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
    Failure? primaryBlocked;
    var wholeMarket = false;
    // Categories fetched as the provider's complete list: their stale rows
    // are replaced, not kept.
    final complete = <QuoteCategory>{};

    // Runs one category unless it wasn't requested or an earlier call
    // already showed that Bürküt can't be used (no/rejected key, quota).
    Future<void> fetch(
      QuoteCategory category,
      Future<Result<List<Quote>>> Function() call, {
      bool isComplete = true,
    }) async {
      if (!categories.contains(category)) return;
      final blocked = primaryBlocked;
      if (blocked != null) {
        failures[category] = blocked;
        return;
      }
      switch (await call()) {
        case Success(:final value):
          quotes.addAll(value);
          if (isComplete && value.isNotEmpty) complete.add(category);
        case Err(:final failure):
          failures[category] = failure;
          if (_blocksPrimary(failure)) primaryBlocked = failure;
      }
    }

    await fetch(QuoteCategory.fx, _fx.fetchRates);
    await fetch(QuoteCategory.metals, _metals.fetchPrices);
    // Stocks: whole market (null) or the given symbols, one request.
    if (stockSymbols == null || stockSymbols.isNotEmpty) {
      final symbols = stockSymbols?.toList()?..sort();
      await fetch(
        QuoteCategory.stocks,
        () => _stocks.fetchQuotes(symbols: symbols),
        isComplete: symbols == null,
      );
      wholeMarket = symbols == null && complete.contains(QuoteCategory.stocks);
    }
    await fetch(QuoteCategory.funds, _funds.fetchFunds);

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

  @override
  Future<Result<QuotaUsage>> syncQuota() async {
    final source = _quotaStatus;
    if (source == null) return quotaUsage();
    final status = await source.fetchQuotaStatus();
    switch (status) {
      case Err(:final failure):
        return Err(failure);
      case Success(:final value):
        try {
          return Success(await _quota.syncStatus(value));
        } on Object catch (error) {
          return Err(StorageFailure(error.toString()));
        }
    }
  }

  static bool _blocksPrimary(Failure f) =>
      f is AuthFailure || f is QuotaExceededFailure;
}
