import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';

/// Outcome of one refresh. Partial success is normal (e.g. FX ok via
/// fallback, metals failed because no API key is set).
class RefreshReport {
  const RefreshReport({
    required this.updated,
    required this.failures,
    this.usedFxFallback = false,
  });

  /// Number of quotes written to the cache.
  final int updated;
  final Map<QuoteCategory, Failure> failures;

  /// FX came from the free fallback instead of the primary provider.
  final bool usedFxFallback;

  bool get hasFailures => failures.isNotEmpty;
}

abstract interface class MarketRepository {
  /// Cached quotes; emits again whenever the cache changes.
  Stream<Result<List<Quote>>> watchQuotes();

  /// Fetches only the given [categories] and stores them. Stocks: the whole
  /// BIST market when [stockSymbols] is `null` (one request), otherwise
  /// only those symbols; an empty set fetches nothing.
  Future<Result<RefreshReport>> refresh({
    required Set<QuoteCategory> categories,
    Set<String>? stockSymbols,
  });

  Future<Result<QuotaUsage>> quotaUsage();

  /// When the whole BIST market was last fetched successfully; `null` if
  /// never (then stocks are fetched even outside the session).
  Future<DateTime?> stocksSnapshotAt();
}
