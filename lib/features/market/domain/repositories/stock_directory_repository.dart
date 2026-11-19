import 'package:capira/core/error/result.dart';
import 'package:capira/features/market/domain/entities/stock_listing.dart';

/// Full BIST stock list for search. Cached on the device and refreshed at
/// most once a week (one request from the monthly quota).
// One method by design: the cache policy lives in the implementation.
// ignore: one_member_abstracts
abstract interface class StockDirectoryRepository {
  /// Cached list if it is fresh; otherwise fetched (needs an API key).
  /// Falls back to a stale cache when fetching fails; `Err` only when
  /// there is nothing cached and fetching failed.
  Future<Result<List<StockListing>>> listings();
}
