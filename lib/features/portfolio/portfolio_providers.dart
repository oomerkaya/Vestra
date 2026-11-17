import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/di/database_provider.dart';
import 'package:vestra/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:vestra/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';
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
