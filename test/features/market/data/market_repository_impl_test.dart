import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:vestra/features/market/data/datasources/quota_local_data_source.dart';
import 'package:vestra/features/market/data/repositories/market_repository_impl.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

class _Fx extends Mock implements FxRateProvider {}

class _Metals extends Mock implements MetalPriceProvider {}

class _Stocks extends Mock implements StockPriceProvider {}

Quote _q(AssetType type, String code, String price, QuoteSource source) =>
    Quote(
      instrument: (type: type, code: code),
      priceTry: d(price),
      source: source,
      fetchedAt: DateTime(2026, 11, 17, 12),
      changePercent: d('1.5'),
    );

final Set<QuoteCategory> _all = QuoteCategory.values.toSet();

void main() {
  late AppDatabase db;
  late _Fx fx;
  late _Fx fallback;
  late _Metals metals;
  late _Stocks stocks;
  late MarketRepositoryImpl repo;

  final usd = _q(AssetType.currency, 'USD', '42.1', QuoteSource.burkut);
  final usdEcb = _q(AssetType.currency, 'USD', '42', QuoteSource.frankfurter);
  final gram = _q(AssetType.gold, 'GRAM', '3500', QuoteSource.burkut);
  final thyao = _q(AssetType.stock, 'THYAO', '312.5', QuoteSource.burkut);

  setUp(() {
    db = createTestDatabase();
    fx = _Fx();
    fallback = _Fx();
    metals = _Metals();
    stocks = _Stocks();
    repo = MarketRepositoryImpl(
      fx: fx,
      fxFallback: fallback,
      metals: metals,
      stocks: stocks,
      cache: PriceCacheLocalDataSource(db),
      quota: QuotaLocalDataSource(db),
    );
    when(
      () => fallback.fetchRates(),
    ).thenAnswer((_) async => Success([usdEcb]));
  });
  tearDown(() => db.close());

  Future<List<Quote>> cached() async =>
      (await repo.watchQuotes().first).valueOrNull!;

  test('happy path stores all categories and skips the fallback', () async {
    when(() => fx.fetchRates()).thenAnswer((_) async => Success([usd]));
    when(() => metals.fetchPrices()).thenAnswer((_) async => Success([gram]));
    when(
      () => stocks.fetchQuotes(symbols: any(named: 'symbols')),
    ).thenAnswer((_) async => Success([thyao]));

    final report = (await repo.refresh(
      categories: _all,
      stockSymbols: {'THYAO'},
    )).valueOrNull!;

    expect(report.updated, 3);
    expect(report.hasFailures, isFalse);
    expect(report.usedFxFallback, isFalse);
    verifyNever(() => fallback.fetchRates());
    final stored = await cached();
    expect(stored, hasLength(3));
    final storedUsd = stored.firstWhere((q) => q.instrument.code == 'USD');
    expect(storedUsd.priceTry, d('42.1'));
    expect(storedUsd.changePercent, d('1.5'));
  });

  test('missing key: FX from fallback, metals/stocks skipped', () async {
    when(
      () => fx.fetchRates(),
    ).thenAnswer((_) async => const Err(AuthFailure(missingKey: true)));

    final report = (await repo.refresh(
      categories: _all,
      stockSymbols: {'THYAO'},
    )).valueOrNull!;

    expect(report.usedFxFallback, isTrue);
    expect(report.failures[QuoteCategory.metals], isA<AuthFailure>());
    expect(report.failures[QuoteCategory.stocks], isA<AuthFailure>());
    expect(report.failures.containsKey(QuoteCategory.fx), isFalse);
    verifyNever(() => metals.fetchPrices());
    verifyNever(() => stocks.fetchQuotes(symbols: any(named: 'symbols')));
    expect((await cached()).single.source, QuoteSource.frankfurter);
  });

  test('network failure on FX still tries metals', () async {
    when(
      () => fx.fetchRates(),
    ).thenAnswer((_) async => const Err(NetworkFailure()));
    when(() => metals.fetchPrices()).thenAnswer((_) async => Success([gram]));

    final report = (await repo.refresh(
      categories: _all,
      stockSymbols: {},
    )).valueOrNull!;

    expect(report.usedFxFallback, isTrue);
    expect(report.updated, 2);
    verify(() => metals.fetchPrices()).called(1);
  });

  test('no stocks held: stock provider is not called', () async {
    when(() => fx.fetchRates()).thenAnswer((_) async => Success([usd]));
    when(() => metals.fetchPrices()).thenAnswer((_) async => Success([gram]));

    await repo.refresh(categories: _all, stockSymbols: {});

    verifyNever(() => stocks.fetchQuotes(symbols: any(named: 'symbols')));
  });

  test('a newer quote replaces the cached one', () async {
    when(() => fx.fetchRates()).thenAnswer((_) async => Success([usd]));
    when(
      () => metals.fetchPrices(),
    ).thenAnswer((_) async => const Success([]));
    await repo.refresh(categories: _all, stockSymbols: {});

    final newer = _q(AssetType.currency, 'USD', '43', QuoteSource.burkut);
    when(() => fx.fetchRates()).thenAnswer((_) async => Success([newer]));
    await repo.refresh(categories: _all, stockSymbols: {});

    expect((await cached()).single.priceTry, d('43'));
  });

  test('everything failing keeps the old cache', () async {
    when(() => fx.fetchRates()).thenAnswer((_) async => Success([usd]));
    when(
      () => metals.fetchPrices(),
    ).thenAnswer((_) async => const Success([]));
    await repo.refresh(categories: _all, stockSymbols: {});

    when(
      () => fx.fetchRates(),
    ).thenAnswer((_) async => const Err(NetworkFailure()));
    when(
      () => fallback.fetchRates(),
    ).thenAnswer((_) async => const Err(NetworkFailure()));
    when(
      () => metals.fetchPrices(),
    ).thenAnswer((_) async => const Err(NetworkFailure()));
    final report = (await repo.refresh(
      categories: _all,
      stockSymbols: {},
    )).valueOrNull!;

    expect(report.updated, 0);
    expect(report.failures.keys, containsAll([QuoteCategory.fx]));
    expect((await cached()).single.priceTry, d('42.1'));
  });

  test('only the requested categories are fetched', () async {
    when(() => metals.fetchPrices()).thenAnswer((_) async => Success([gram]));

    final report = (await repo.refresh(
      categories: {QuoteCategory.metals},
      stockSymbols: {'THYAO'},
    )).valueOrNull!;

    expect(report.updated, 1);
    verifyNever(() => fx.fetchRates());
    verifyNever(() => fallback.fetchRates());
    verifyNever(() => stocks.fetchQuotes(symbols: any(named: 'symbols')));
  });

  test('stockSymbols null = whole market in one request', () async {
    when(() => fx.fetchRates()).thenAnswer((_) async => Success([usd]));
    when(() => metals.fetchPrices()).thenAnswer((_) async => Success([gram]));
    when(
      () => stocks.fetchQuotes(symbols: any(named: 'symbols')),
    ).thenAnswer((_) async => Success([thyao]));

    await repo.refresh(categories: _all);

    verify(() => stocks.fetchQuotes()).called(1);
  });

  group('ounce gold (USD) is stored in TRY', () {
    final onsUsd = Quote(
      instrument: (type: AssetType.gold, code: 'ONS'),
      priceTry: d('2500'),
      source: QuoteSource.burkut,
      fetchedAt: DateTime(2026, 11, 18),
      currency: 'USD',
    );

    test('with the USD rate from the same refresh', () async {
      when(() => fx.fetchRates()).thenAnswer((_) async => Success([usd]));
      when(
        () => metals.fetchPrices(),
      ).thenAnswer((_) async => Success([onsUsd]));

      await repo.refresh(categories: _all, stockSymbols: const {});

      final ons = (await cached()).firstWhere(
        (q) => q.instrument.code == 'ONS',
      );
      expect(ons.priceTry, d('105250')); // 2500 x 42.1
      expect(ons.currency, 'TRY');
    });

    test('with the cached USD rate when FX is not refreshed', () async {
      when(() => fx.fetchRates()).thenAnswer((_) async => Success([usd]));
      when(
        () => metals.fetchPrices(),
      ).thenAnswer((_) async => const Success([]));
      await repo.refresh(categories: _all, stockSymbols: const {});
      when(
        () => metals.fetchPrices(),
      ).thenAnswer((_) async => Success([onsUsd]));

      await repo.refresh(categories: {QuoteCategory.metals});

      final ons = (await cached()).firstWhere(
        (q) => q.instrument.code == 'ONS',
      );
      expect(ons.priceTry, d('105250'));
    });

    test('dropped when no USD rate is known', () async {
      when(
        () => metals.fetchPrices(),
      ).thenAnswer((_) async => Success([onsUsd]));

      await repo.refresh(categories: {QuoteCategory.metals});

      expect(await cached(), isEmpty);
    });
  });
}
