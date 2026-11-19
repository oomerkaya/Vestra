import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:vestra/core/di/database_provider.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/services/disclosure_policy.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:vestra/features/portfolio/data/repositories/backup_repository_impl.dart';
import 'package:vestra/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/holding.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:vestra/features/portfolio/domain/repositories/backup_repository.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:vestra/features/portfolio/domain/services/portfolio_valuator.dart';
import 'package:vestra/features/portfolio/domain/usecases/add_transaction.dart';
import 'package:vestra/features/portfolio/domain/usecases/backup_use_cases.dart';
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

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepositoryImpl(
    PortfolioLocalDataSource(ref.watch(appDatabaseProvider)),
  ),
);

final exportPortfolioProvider = Provider<ExportPortfolio>(
  (ref) => ExportPortfolio(ref.watch(backupRepositoryProvider)),
);

final readBackupProvider = Provider<ReadBackup>(
  (ref) => ReadBackup(ref.watch(backupRepositoryProvider)),
);

final restoreBackupProvider = Provider<RestoreBackup>(
  (ref) => RestoreBackup(ref.watch(backupRepositoryProvider)),
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

/// Instruments currently held (quantity > 0), for "Portföyümde" lists.
final heldInstrumentsProvider = Provider<Set<Instrument>>(
  (ref) => {
    for (final h in ref.watch(holdingsProvider).value ?? const <Holding>[])
      if (h.quantity > Decimal.zero) (type: h.asset.type, code: h.asset.code),
  },
);

/// Symbols of held stocks.
final heldStockSymbolsProvider = Provider<Set<String>>(
  (ref) => {
    for (final i in ref.watch(heldInstrumentsProvider))
      if (i.type == AssetType.stock) i.code,
  },
);

/// Stored KAP disclosures of held stocks (last 30 days), newest first,
/// live. Read from storage only; never sends a request.
final heldDisclosuresProvider = StreamProvider<List<KapDisclosure>>((ref) {
  final held = ref.watch(heldStockSymbolsProvider);
  if (held.isEmpty) return Stream.value(const []);
  return ref
      .watch(disclosureRepositoryProvider)
      .watchForSymbols(held)
      .map(
        (result) => switch (result) {
          Success(:final value) => value,
          Err(:final failure) => throw failure,
        },
      );
});

/// Disclosures published since the list was last opened (the last 7 days
/// before it was ever opened); drives the badge on the portfolio screen.
final kapUnseenCountProvider = Provider<int>((ref) {
  final seenAt =
      ref.watch(kapSeenAtProvider).value ??
      DateTime.now().subtract(const Duration(days: 7));
  return (ref.watch(heldDisclosuresProvider).value ?? const <KapDisclosure>[])
      .where((d) => d.publishedAt.isAfter(seenAt))
      .length;
});

/// Held stocks with a disclosure in the last 24 hours.
final newDisclosureSymbolsProvider = Provider<Set<String>>((ref) {
  final since = DateTime.now().subtract(DisclosurePolicy.newWindow);
  return {
    for (final d
        in ref.watch(heldDisclosuresProvider).value ?? const <KapDisclosure>[])
      if (d.publishedAt.isAfter(since)) d.symbol,
  };
});
