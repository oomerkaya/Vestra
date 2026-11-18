import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/data/datasources/burkut_remote_data_source.dart';
import 'package:vestra/features/market/data/datasources/frankfurter_remote_data_source.dart';
import 'package:vestra/features/market/data/datasources/quota_local_data_source.dart';
import 'package:vestra/features/market/data/dto/burkut_dtos.dart';
import 'package:vestra/features/market/data/providers/burkut_price_provider.dart';
import 'package:vestra/features/market/data/providers/frankfurter_fx_provider.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

class _MockBurkut extends Mock implements BurkutRemoteDataSource {}

class _MockFrankfurter extends Mock implements FrankfurterRemoteDataSource {}

/// Builds a response from raw JSON items, as the API would send them.
BurkutResponse _response(
  List<Map<String, dynamic>> items, {
  int? remaining,
}) => BurkutResponse([
  for (final json in items) ?BurkutPriceDto.fromJson(json),
], quotaRemaining: remaining);

void main() {
  late AppDatabase db;
  late QuotaLocalDataSource quota;
  late _MockBurkut remote;
  String? key;

  final now = DateTime(2026, 11, 17, 12);

  setUp(() {
    db = createTestDatabase();
    quota = QuotaLocalDataSource(db, clock: () => now);
    remote = _MockBurkut();
    key = 'bk_live_test_key_123';
  });
  tearDown(() => db.close());

  BurkutPriceProvider provider() => BurkutPriceProvider(
    remote: remote,
    readApiKey: () async => key,
    quota: quota,
    clock: () => now,
  );

  group('BurkutPriceProvider', () {
    test('forex: REST spec shape (price only) is mapped', () async {
      when(() => remote.getForex(any())).thenAnswer(
        (_) async => _response([
          // Sample item from Bürküt's REST spec.
          {
            'symbol': 'USD',
            'name': 'Amerikan Doları',
            'price': 38.42,
            'changePercent': 0.15,
            'updatedAt': '2026-10-15T15:30:00Z',
          },
          {'symbol': 'XAU', 'price': 1}, // metal code: skipped
          {'symbol': 'GRAM-ALTIN', 'price': 1}, // not ISO: skipped
        ]),
      );

      final quotes = (await provider().fetchRates()).valueOrNull!;

      expect(quotes, hasLength(1));
      final usd = quotes.single;
      expect(usd.instrument, (type: AssetType.currency, code: 'USD'));
      expect(usd.priceTry, d('38.42'));
      expect(usd.changePercent, d('0.15'));
      expect(usd.asOf, DateTime.utc(2026, 10, 15, 15, 30));
      expect((await quota.current()).used, 1);
    });

    test('forex: SDK shape (buying/change_rate) still works', () async {
      when(() => remote.getForex(any())).thenAnswer(
        (_) async => _response([
          {'symbol': 'EUR', 'buying': 42.1, 'selling': 42.2, 'change_rate': -1},
        ]),
      );

      final eur = (await provider().fetchRates()).valueOrNull!.single;

      expect(eur.priceTry, d('42.1'));
      expect(eur.changePercent, d('-1'));
    });

    test('forex: USDTRY / USD/TRY symbols are normalised', () async {
      when(() => remote.getForex(any())).thenAnswer(
        (_) async => _response([
          {'symbol': 'USDTRY', 'price': 38},
          {'symbol': 'EUR/TRY', 'price': 42},
        ]),
      );

      final codes = (await provider().fetchRates()).valueOrNull!.map(
        (q) => q.instrument.code,
      );

      expect(codes, ['USD', 'EUR']);
    });

    test(
      'gold: spec symbols, buying price, ounce kept in USD',
      () async {
        when(() => remote.getGold(any())).thenAnswer(
          (_) async => _response([
            {
              'symbol': 'ALTIN',
              'unit': 'TL/Gr',
              'buying': 3178.2,
              'selling': 3180.5,
              'price': 3180.5,
              'dailyChangePct': 0.62,
            },
            {
              'symbol': 'XAUUSD',
              'unit': 'USD/Ons',
              'buying': 2574.1,
              'price': 2574.8,
            },
            {'symbol': 'CEYREK_YENI', 'unit': 'TL/Adet', 'buying': 5180},
            {'symbol': 'YARIM', 'unit': 'TL/Adet', 'buying': 10360},
            {'symbol': 'TAM', 'unit': 'TL/Adet', 'buying': 20720},
            {'symbol': 'CUMHURIYET', 'unit': 'TL/Adet', 'buying': 21300},
            {'symbol': 'ATA', 'unit': 'TL/Adet', 'buying': 21400},
            {'symbol': 'GUMTRY', 'unit': 'TL/Gr', 'buying': 42},
            {'symbol': 'PLATIN', 'unit': 'TL/Gr', 'buying': 1500},
          ]),
        );

        final quotes = (await provider().fetchPrices()).valueOrNull!;

        expect(quotes.map((q) => q.instrument), [
          (type: AssetType.gold, code: 'GRAM'),
          (type: AssetType.gold, code: 'ONS'),
          (type: AssetType.gold, code: 'CEYREK'),
          (type: AssetType.gold, code: 'YARIM'),
          (type: AssetType.gold, code: 'TAM'),
          (type: AssetType.gold, code: 'CUMHURIYET'),
          (type: AssetType.gold, code: 'ATA'),
          (type: AssetType.silver, code: 'SILVER_GRAM'),
        ]);
        expect(quotes.first.priceTry, d('3178.2'), reason: 'buying, not price');
        final ons = quotes.firstWhere((q) => q.instrument.code == 'ONS');
        expect(ons.currency, 'USD', reason: 'converted by the repository');
        expect(quotes.first.currency, 'TRY');
        expect(quotes.first.changePercent, d('0.62'));
      },
    );

    test('server X-Quota-Remaining overrides the local estimate', () async {
      when(
        () => remote.getGold(any()),
      ).thenAnswer((_) async => _response([], remaining: 688));

      await provider().fetchPrices();

      final usage = await quota.current();
      expect(usage.used, 312);
      expect(usage.isExhausted, isFalse);
    });

    test('X-Quota-Remaining of 0 marks the quota exhausted', () async {
      when(
        () => remote.getGold(any()),
      ).thenAnswer((_) async => _response([], remaining: 0));

      await provider().fetchPrices();

      expect((await quota.current()).isExhausted, isTrue);
    });

    test('no key: fails without sending a request', () async {
      key = null;

      final result = await provider().fetchRates();

      expect(
        result,
        isA<Err<List<Quote>>>().having(
          (e) => (e.failure as AuthFailure).missingKey,
          'missingKey',
          isTrue,
        ),
      );
      verifyZeroInteractions(remote);
      expect((await quota.current()).used, 0);
    });

    test('exhausted quota: fails without sending a request', () async {
      await quota.markExhausted();

      final result = await provider().fetchPrices();

      expect((result as Err).failure, isA<QuotaExceededFailure>());
      verifyZeroInteractions(remote);
    });

    test('server quota answer marks the local counter exhausted', () async {
      when(() => remote.getForex(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/forex'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/forex'),
            statusCode: 429,
            data: {'error': 'MONTHLY_QUOTA_EXCEEDED'},
          ),
        ),
      );

      final result = await provider().fetchRates();

      expect((result as Err).failure, isA<QuotaExceededFailure>());
      expect((await quota.current()).isExhausted, isTrue);
    });

    test('stocks: spec shape, one request, empty list sends nothing', () async {
      when(
        () => remote.getStocks(any(), symbols: any(named: 'symbols')),
      ).thenAnswer(
        (_) async => _response([
          {
            'symbol': 'THYAO',
            'name': 'TURK HAVA YOLLARI',
            'price': 304.5,
            'change': 7.25,
            'changePercent': 2.44,
          },
        ]),
      );

      expect((await provider().fetchQuotes(symbols: [])).valueOrNull, isEmpty);
      verifyNever(
        () => remote.getStocks(any(), symbols: any(named: 'symbols')),
      );

      final thyao = (await provider().fetchQuotes(
        symbols: ['THYAO', 'ASELS'],
      )).valueOrNull!.single;
      expect(thyao.instrument, (type: AssetType.stock, code: 'THYAO'));
      expect(thyao.priceTry, d('304.5'));
      expect(thyao.changePercent, d('2.44'));
      verify(
        () => remote.getStocks(any(), symbols: ['THYAO', 'ASELS']),
      ).called(1);
      expect((await quota.current()).used, 1);
    });

    test('validate() sends one request with the candidate key', () async {
      when(() => remote.getForex(any())).thenAnswer((_) async => _response([]));

      final result = await provider().validate('bk_live_candidate_1');

      expect(result.isSuccess, isTrue);
      verify(() => remote.getForex('bk_live_candidate_1')).called(1);
    });
  });

  group('FrankfurterFxProvider', () {
    test('inverts per-TRY rates to TRY per unit', () async {
      final remote = _MockFrankfurter();
      when(() => remote.latestPerTry(any())).thenAnswer(
        (_) async => (
          date: DateTime.utc(2026, 11, 17),
          perTry: {'USD': d('0.02'), 'EUR': d('0.016'), 'BAD': Decimal.zero},
        ),
      );

      final quotes = (await FrankfurterFxProvider(
        remote,
        clock: () => now,
      ).fetchRates()).valueOrNull!;

      final byCode = {for (final q in quotes) q.instrument.code: q};
      expect(byCode['USD']!.priceTry, d('50'));
      expect(byCode['EUR']!.priceTry, d('62.5'));
      expect(byCode.containsKey('BAD'), isFalse);
      expect(byCode['USD']!.source, QuoteSource.frankfurter);
      expect(byCode['USD']!.asOf, DateTime.utc(2026, 11, 17));
    });
  });

  group('QuotaLocalDataSource', () {
    test('counts per month and resets in a new month', () async {
      var clock = DateTime(2026, 11, 30, 23);
      final q = QuotaLocalDataSource(db, clock: () => clock);

      await q.recordRequest();
      await q.recordRequest();
      expect((await q.current()).used, 2);
      expect((await q.current()).period, '2026-11');

      clock = DateTime(2026, 12, 1, 9);
      expect((await q.current()).used, 0);
      expect((await q.current()).period, '2026-12');
    });

    test('remaining is limit minus used', () async {
      for (var i = 0; i < 3; i++) {
        await quota.recordRequest();
      }
      final usage = await quota.current();
      expect(usage.remaining, 997);
      expect(usage.isExhausted, isFalse);
    });

    test('syncRemaining clamps values above the free limit', () async {
      final usage = await quota.syncRemaining(49000);
      expect(usage.used, 0);
      expect(usage.isExhausted, isFalse);
    });
  });
}
