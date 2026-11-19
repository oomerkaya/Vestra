import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/core/utils/app_logger.dart';
import 'package:capira/features/market/data/datasources/stock_listing_local_data_source.dart';
import 'package:capira/features/market/domain/entities/stock_listing.dart';
import 'package:capira/features/market/domain/providers/price_providers.dart';
import 'package:capira/features/market/domain/repositories/stock_directory_repository.dart';

class StockDirectoryRepositoryImpl implements StockDirectoryRepository {
  StockDirectoryRepositoryImpl({
    required this._provider,
    required this._local,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const Duration maxAge = Duration(days: 7);

  final StockListingProvider _provider;
  final StockListingLocalDataSource _local;
  final DateTime Function() _clock;

  @override
  Future<Result<List<StockListing>>> listings() async {
    final cached = await _readCache();
    final now = _clock();
    if (cached != null && now.difference(cached.fetchedAt) < maxAge) {
      return Success(cached.items);
    }
    switch (await _provider.fetchListings()) {
      case Success(:final value) when value.isNotEmpty:
        final sorted = [...value]..sort((a, b) => a.symbol.compareTo(b.symbol));
        try {
          await _local.write(now, sorted);
        } on Object catch (e) {
          AppLogger.warning('stock list cache write failed: $e');
        }
        return Success(sorted);
      case Success():
        return cached != null
            ? Success(cached.items)
            : const Err(ServerFailure(message: 'empty stock list'));
      case Err(:final failure):
        return cached != null ? Success(cached.items) : Err(failure);
    }
  }

  Future<({DateTime fetchedAt, List<StockListing> items})?> _readCache() async {
    try {
      return await _local.read();
    } on Object {
      return null;
    }
  }
}
