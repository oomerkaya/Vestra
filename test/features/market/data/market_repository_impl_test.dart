import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/data/datasources/market_meta_local_data_source.dart';
import 'package:vestra/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:vestra/features/market/data/datasources/quota_local_data_source.dart';
import 'package:vestra/features/market/data/mappers/quote_mappers.dart';
import 'package:vestra/features/market/data/repositories/market_repository_impl.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

class _Fx extends Mock implements FxRateProvider {}

class _Metals extends Mock implements MetalPriceProvider {}

class _Stocks extends Mock implements StockPriceProvider {}

class _Funds extends Mock implements FundPriceProvider {}

Quote _q(AssetType type, String code, String price) => Quote(
  instrument: (type: type, code: code),
  priceTry: d(price),
  source: QuoteSource.burkut,
  fetchedAt: DateTime(2026, 11, 17, 12),
  changePercent: d('1.5'),
);

final Set<QuoteCategory> _all = QuoteCategory.values.toSet();

void main() {
  late AppDatabase db;
  late _Fx fx;
  late _Metals metals;
  late _Stocks stocks;
  late _Funds funds;
  late MarketRepositoryImpl repo;
  final now = DateTime.utc(2026, 11, 18, 12);

  final usd = _q(AssetType.currency, 'USD', '42.1');
  final gbp = _q(AssetType.currency, 'GBP', '56');
  final gram = _q(AssetType.gold, 'GRAM', '3500');
  final ons = _q(AssetType.gold, 'ONS', '176000');
  final thyao = _q(AssetType.stock, 'THYAO', '312.5');
  final tcd = _q(AssetType.fund, 'TCD', '43.4046');

  setUp(() {
    db = createTestDatabase();
    fx = _Fx();
    metals = _Metals();
    stocks = _Stocks();
    funds = _Funds();
    repo = MarketRepositoryImpl(
      fx: fx,
      metals: metals,
      stocks: stocks,
      funds: funds,
      cache: PriceCacheLocalDataSource(db),
      quota: QuotaLocalDataSource(db),
      meta: MarketMetaLocalDataSource(db),
      clock: () => now,
    );
    when(() => fx.fetchRates()).thenAnswer((_) async => Success([usd]));
    when(() => metals.fetchPrices()).thenAnswer((_) async => Success([gram]));
    when(
      () => stocks.fetchQuotes(symbols: any(named: 'symbols')),
    ).thenAnswer((_) async => Success([thyao]));
    when(() => funds.fetchFunds()).thenAnswer((_) async => Success([tcd]));
  });
  tearDown(() => db.close());

  Future<List<Quote>> cached() async =>
      (await repo.watchQuotes().first).valueOrNull!;

  test('all four categories are fetched and stored', () async {
    final report = (await repo.refresh(categories: _all)).valueOrNull!;

    expect(report.updated, 4);
    expect(report.hasFailures, isFalse);
    final codes = (await cached()).map((q) => q.instrument.code).toSet();
    expect(codes, {'USD', 'GRAM', 'THYAO', 'TCD'});
    verify(() => stocks.fetchQuotes()).called(1);
  });

  test('only the requested categories are fetched', () async {
    await repo.refresh(categories: {QuoteCategory.funds});

    verify(() => funds.fetchFunds()).called(1);
    verifyNever(() => fx.fetchRates());
    verifyNever(() => metals.fetchPrices());
    verifyNever(() => stocks.fetchQuotes(symbols: any(named: 'symbols')));
  });

  test('missing key: nothing is fetched, every category fails', () async {
    when(
      () => fx.fetchRates(),
    ).thenAnswer((_) async => const Err(AuthFailure(missingKey: true)));

    final report = (await repo.refresh(categories: _all)).valueOrNull!;

    expect(report.updated, 0);
    expect(report.failures.keys.toSet(), _all);
    expect(report.failures.values, everyElement(isA<AuthFailure>()));
    verifyNever(() => metals.fetchPrices());
    verifyNever(() => stocks.fetchQuotes(symbols: any(named: 'symbols')));
    verifyNever(() => funds.fetchFunds());
  });

  test('a network failure on one category still tries the others', () async {
    when(
      () => fx.fetchRates(),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    final report = (await repo.refresh(categories: _all)).valueOrNull!;

    expect(report.failures.keys, [QuoteCategory.fx]);
    expect(report.updated, 3);
  });

  test('a newer quote replaces the cached one', () async {
    await repo.refresh(categories: {QuoteCategory.fx});
    final newer = _q(AssetType.currency, 'USD', '43');
    when(() => fx.fetchRates()).thenAnswer((_) async => Success([newer]));

    await repo.refresh(categories: {QuoteCategory.fx});

    expect((await cached()).single.priceTry, d('43'));
  });

  test('everything failing keeps the old cache', () async {
    await repo.refresh(categories: {QuoteCategory.fx});
    when(
      () => fx.fetchRates(),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    final report = (await repo.refresh(
      categories: {QuoteCategory.fx},
    )).valueOrNull!;

    expect(report.updated, 0);
    expect((await cached()).single.priceTry, d('42.1'));
  });

  test('empty stockSymbols fetches no stocks', () async {
    await repo.refresh(
      categories: {QuoteCategory.stocks},
      stockSymbols: const {},
    );

    verifyNever(() => stocks.fetchQuotes(symbols: any(named: 'symbols')));
  });

  group('stocks snapshot', () {
    test('a whole-market fetch records the snapshot time', () async {
      expect(await repo.stocksSnapshotAt(), isNull);

      await repo.refresh(categories: {QuoteCategory.stocks});

      expect(await repo.stocksSnapshotAt(), now);
    });

    test('fetching only some symbols is not a snapshot', () async {
      await repo.refresh(
        categories: {QuoteCategory.stocks},
        stockSymbols: {'THYAO'},
      );

      expect(await repo.stocksSnapshotAt(), isNull);
    });
  });

  group('stale rows', () {
    test('unsupported metals in the cache are not shown', () async {
      await PriceCacheLocalDataSource(db).upsertAll([
        ons.toCompanion(),
        gram.toCompanion(),
      ]);

      expect((await cached()).map((q) => q.instrument.code), ['GRAM']);
    });

    test('a complete list removes rows it no longer contains', () async {
      await PriceCacheLocalDataSource(db).upsertAll([
        ons.toCompanion(),
        gbp.toCompanion(),
      ]);

      await repo.refresh(categories: {QuoteCategory.metals, QuoteCategory.fx});

      final rows = await db.select(db.priceCache).get();
      expect(rows.map((r) => r.code).toSet(), {'GRAM', 'USD'});
    });

    test('a failed category keeps its rows', () async {
      await PriceCacheLocalDataSource(db).upsertAll([gbp.toCompanion()]);
      when(
        () => fx.fetchRates(),
      ).thenAnswer((_) async => const Err(NetworkFailure()));

      await repo.refresh(categories: {QuoteCategory.fx});

      expect((await cached()).single.instrument.code, 'GBP');
    });

    test('an empty answer never wipes the cache', () async {
      await PriceCacheLocalDataSource(db).upsertAll([gram.toCompanion()]);
      when(
        () => metals.fetchPrices(),
      ).thenAnswer((_) async => const Success([]));

      await repo.refresh(categories: {QuoteCategory.metals});

      expect((await cached()).single.instrument.code, 'GRAM');
    });
  });
}
