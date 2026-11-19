import 'dart:convert';

import 'package:capira/core/di/database_provider.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/core/network/dio_factory.dart';
import 'package:capira/core/utils/app_logger.dart';
import 'package:capira/features/market/data/datasources/burkut_remote_data_source.dart';
import 'package:capira/features/market/data/datasources/kap_disclosure_local_data_source.dart';
import 'package:capira/features/market/data/datasources/market_meta_local_data_source.dart';
import 'package:capira/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:capira/features/market/data/datasources/quota_local_data_source.dart';
import 'package:capira/features/market/data/datasources/stock_listing_local_data_source.dart';
import 'package:capira/features/market/data/providers/burkut_price_provider.dart';
import 'package:capira/features/market/data/repositories/disclosure_repository_impl.dart';
import 'package:capira/features/market/data/repositories/market_repository_impl.dart';
import 'package:capira/features/market/data/repositories/stock_directory_repository_impl.dart';
import 'package:capira/features/market/domain/entities/market_calendar.dart';
import 'package:capira/features/market/domain/entities/quota_usage.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/domain/entities/stock_listing.dart';
import 'package:capira/features/market/domain/repositories/disclosure_repository.dart';
import 'package:capira/features/market/domain/repositories/market_repository.dart';
import 'package:capira/features/market/domain/repositories/stock_directory_repository.dart';
import 'package:capira/features/settings/domain/usecases/save_burkut_key.dart';
import 'package:capira/features/settings/settings_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quotaLocalDataSourceProvider = Provider<QuotaLocalDataSource>(
  (ref) => QuotaLocalDataSource(ref.watch(appDatabaseProvider)),
);

final burkutPriceProviderProvider = Provider<BurkutPriceProvider>((ref) {
  final apiKeys = ref.watch(apiKeyRepositoryProvider);
  return BurkutPriceProvider(
    remote: BurkutRemoteDataSource(
      createDio(baseUrl: BurkutRemoteDataSource.baseUrl),
    ),
    readApiKey: () async => (await apiKeys.readBurkutKey()).valueOrNull,
    quota: ref.watch(quotaLocalDataSourceProvider),
  );
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final burkut = ref.watch(burkutPriceProviderProvider);
  return MarketRepositoryImpl(
    fx: burkut,
    metals: burkut,
    stocks: burkut,
    funds: burkut,
    cache: PriceCacheLocalDataSource(ref.watch(appDatabaseProvider)),
    quota: ref.watch(quotaLocalDataSourceProvider),
    meta: MarketMetaLocalDataSource(ref.watch(appDatabaseProvider)),
    quotaStatus: burkut,
  );
});

/// Cached quotes, live.
final quotesProvider = StreamProvider<List<Quote>>(
  (ref) => ref
      .watch(marketRepositoryProvider)
      .watchQuotes()
      .map(
        (result) => switch (result) {
          Success(:final value) => value,
          Err(:final failure) => throw failure,
        },
      ),
);

final quotaUsageProvider = FutureProvider<QuotaUsage?>(
  (ref) async =>
      (await ref.watch(marketRepositoryProvider).quotaUsage()).valueOrNull,
);

/// Holiday calendar from `assets/data/market_holidays.json`. Falls back to
/// an empty calendar (weekends only) if the asset can't be read.
final marketCalendarProvider = FutureProvider<MarketCalendar>((ref) async {
  try {
    final raw = await rootBundle.loadString('assets/data/market_holidays.json');
    return MarketCalendar.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } on Object catch (error) {
    AppLogger.warning('market calendar unavailable: $error');
    return MarketCalendar.empty;
  }
});

/// Turned off in widget tests so no timers or network calls start.
final autoRefreshEnabledProvider = Provider<bool>((ref) => true);

/// The stored Bürküt key (for status display); `null` when not set.
final burkutKeyProvider = FutureProvider<String?>(
  (ref) async =>
      (await ref.watch(apiKeyRepositoryProvider).readBurkutKey()).valueOrNull,
);

final saveBurkutKeyProvider = Provider<SaveBurkutKey>(
  (ref) => SaveBurkutKey(
    ref.watch(apiKeyRepositoryProvider),
    ref.watch(burkutPriceProviderProvider),
  ),
);

final stockDirectoryRepositoryProvider = Provider<StockDirectoryRepository>(
  (ref) => StockDirectoryRepositoryImpl(
    provider: ref.watch(burkutPriceProviderProvider),
    local: StockListingLocalDataSource(ref.watch(appDatabaseProvider)),
  ),
);

/// BIST stock list for the search field (cached, weekly refresh).
final stockListingsProvider = FutureProvider<List<StockListing>>((ref) async {
  final result = await ref.watch(stockDirectoryRepositoryProvider).listings();
  return switch (result) {
    Success(:final value) => value,
    Err(:final failure) => throw failure,
  };
});

final disclosureRepositoryProvider = Provider<DisclosureRepository>(
  (ref) => DisclosureRepositoryImpl(
    provider: ref.watch(burkutPriceProviderProvider),
    local: KapDisclosureLocalDataSource(ref.watch(appDatabaseProvider)),
  ),
);

/// When the disclosure list was last opened (`null` = never), live.
final kapSeenAtProvider = StreamProvider<DateTime?>(
  (ref) => ref.watch(disclosureRepositoryProvider).watchSeenAt(),
);
