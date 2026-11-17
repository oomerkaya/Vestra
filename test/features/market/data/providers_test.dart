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
    test('maps forex and counts one request', () async {
      when(() => remote.getForex(any())).thenAnswer(
        (_) async => [
          BurkutRateDto(symbol: 'USD', buying: d('42.10'), selling: d('42.2')),
          BurkutRateDto(symbol: 'XAU', buying: d('1')), // metal code: skipped
          BurkutRateDto(symbol: 'GRAM-ALTIN', buying: d('1')), // skipped
        ],
      );

      final result = await provider().fetchRates();

      final quotes = result.valueOrNull!;
      expect(quotes.first.instrument, (
        type: AssetType.currency,
        code: 'USD',
      ));
      expect(quotes.first.priceTry, d('42.10'), reason: 'uses buying price');
      expect(quotes, hasLength(1));
      expect((await quota.current()).used, 1);
    });

    test('maps known gold/silver symbols and ignores unknown ones', () async {
      when(() => remote.getGold(any())).thenAnswer(
        (_) async => [
          BurkutRateDto(symbol: 'ALTIN', buying: d('3500')),
          BurkutRateDto(symbol: 'CEYREK_YENI', buying: d('5700')),
          BurkutRateDto(symbol: 'GUMUS', buying: d('42')),
          BurkutRateDto(symbol: 'BILINMEYEN', buying: d('1')),
        ],
      );

      final quotes = (await provider().fetchPrices()).valueOrNull!;

      expect(
        quotes.map((q) => q.instrument),
        [
          (type: AssetType.gold, code: 'GRAM'),
          (type: AssetType.gold, code: 'CEYREK'),
          (type: AssetType.silver, code: 'SILVER_GRAM'),
        ],
      );
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

    test('stocks: one batched request, empty list sends nothing', () async {
      when(() => remote.getStocks(any(), any())).thenAnswer(
        (_) async => [BurkutStockDto(symbol: 'THYAO', lastPrice: d('312.5'))],
      );

      expect((await provider().fetchQuotes([])).valueOrNull, isEmpty);
      verifyNever(() => remote.getStocks(any(), any()));

      final quotes = (await provider().fetchQuotes([
        'THYAO',
        'ASELS',
      ])).valueOrNull!;
      expect(quotes.single.instrument, (type: AssetType.stock, code: 'THYAO'));
      verify(() => remote.getStocks(any(), ['THYAO', 'ASELS'])).called(1);
      expect((await quota.current()).used, 1);
    });

    test('validate() sends one request with the candidate key', () async {
      when(() => remote.getForex(any())).thenAnswer((_) async => []);

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

    test('is exhausted at the limit', () async {
      for (var i = 0; i < 3; i++) {
        await quota.recordRequest();
      }
      final usage = await quota.current();
      expect(usage.remaining, 997);
      expect(usage.isExhausted, isFalse);
    });
  });
}
