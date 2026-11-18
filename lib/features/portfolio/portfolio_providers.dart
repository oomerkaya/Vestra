import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:vestra/core/di/database_provider.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:vestra/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/holding.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:vestra/features/portfolio/domain/services/portfolio_valuator.dart';
import 'package:vestra/features/portfolio/domain/usecases/add_transaction.dart';
import 'package:vestra/features/portfolio/domain/usecases/delete_asset.dart';
import 'package:vestra/features/portfolio/domain/usecases/delete_transaction.dart';
import 'package:vestra/features/portfolio/domain/usecases/update_transaction.dart';
import 'package:vestra/features/portfolio/domain/usecases/watch_asset_transactions.dart';
import 'package:vestra/features/portfolio/domain/usecases/watch_holdings.dart';

/// Wiring for the portfolio feature. Presentation reads use cases from here
/// and never touches the data layer directly.

final portfolioRepositoryProvider = Provider<PortfolioRepository>(
  (ref) => PortfolioRepositoryImpl(
    PortfolioLocalDataSource(ref.watch(appDatabaseProvider)),
  ),
);

final addTransactionProvider = Provider<AddTransaction>(
  (ref) => AddTransaction(ref.watch(portfolioRepositoryProvider)),
);

final updateTransactionProvider = Provider<UpdateTransaction>(
  (ref) => UpdateTransaction(ref.watch(portfolioRepositoryProvider)),
);

final deleteTransactionProvider = Provider<DeleteTransaction>(
  (ref) => DeleteTransaction(ref.watch(portfolioRepositoryProvider)),
);

final deleteAssetProvider = Provider<DeleteAsset>(
  (ref) => DeleteAsset(ref.watch(portfolioRepositoryProvider)),
);

final watchHoldingsProvider = Provider<WatchHoldings>(
  (ref) => WatchHoldings(ref.watch(portfolioRepositoryProvider)),
);

final watchAssetTransactionsProvider = Provider<WatchAssetTransactions>(
  (ref) => WatchAssetTransactions(ref.watch(portfolioRepositoryProvider)),
);

/// All holdings (including closed ones), live.
final holdingsProvider = StreamProvider<List<Holding>>(
  (ref) => ref
      .watch(watchHoldingsProvider)()
      .map(
        (result) => switch (result) {
          Success(:final value) => value,
          Err(:final failure) => throw failure,
        },
      ),
);

/// Portfolio valued with the cached prices; recomputed when either the
/// portfolio or the prices change.
final portfolioSummaryProvider = Provider<AsyncValue<PortfolioSummary>>((
  ref,
) {
  final holdings = ref.watch(holdingsProvider);
  final quotes = ref.watch(quotesProvider);
  if (holdings.hasError) {
    return AsyncError(holdings.error!, holdings.stackTrace!);
  }
  final h = holdings.value;
  if (h == null) return const AsyncLoading();
  return AsyncData(
    PortfolioValuator.value(h, quotes.value ?? const <Quote>[]),
  );
});

/// One asset's transactions, newest first.
final StreamProviderFamily<List<AssetTransaction>, int>
assetTransactionsProvider = StreamProvider.family<List<AssetTransaction>, int>(
  (ref, assetId) => ref
      .watch(watchAssetTransactionsProvider)(assetId)
      .map(
        (result) => switch (result) {
          Success(:final value) => value,
          Err(:final failure) => throw failure,
        },
      ),
);
