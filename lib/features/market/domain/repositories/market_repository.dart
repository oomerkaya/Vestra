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

  /// Fetches FX, metals and the given stock symbols and stores them.
  Future<Result<RefreshReport>> refresh({required Set<String> stockSymbols});

  Future<Result<QuotaUsage>> quotaUsage();
}
