import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/features/market/data/datasources/burkut_remote_data_source.dart';
import 'package:vestra/features/market/data/datasources/quota_local_data_source.dart';
import 'package:vestra/features/market/data/providers/burkut_price_provider.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

/// Regression tests on real Bürküt responses captured on 2026-11-18/19
/// (`test/fixtures/burkut/*.json`, no API key inside). If Bürküt changes
/// its format, refresh the fixtures and these tests show what broke.
class _FixtureAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final name = options.path.replaceAll('/', '');
    final body = File('test/fixtures/burkut/$name.json').readAsStringSync();
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'x-quota-limit': ['1000'],
        'x-quota-remaining': ['997'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late AppDatabase db;
  late QuotaLocalDataSource quota;
  late BurkutPriceProvider provider;

  setUp(() {
    db = createTestDatabase();
    quota = QuotaLocalDataSource(db);
    final dio = Dio(BaseOptions(baseUrl: BurkutRemoteDataSource.baseUrl))
      ..httpClientAdapter = _FixtureAdapter();
    provider = BurkutPriceProvider(
      remote: BurkutRemoteDataSource(dio),
      readApiKey: () async => 'bk_live_fake',
      quota: quota,
    );
  });
  tearDown(() => db.close());

  Map<String, Quote> byCode(List<Quote> quotes) => {
    for (final q in quotes) q.instrument.code: q,
  };

  test(
    '/forex: all real currencies parsed from buyRate, XDR skipped',
    () async {
      final raw =
          jsonDecode(File('test/fixtures/burkut/forex.json').readAsStringSync())
              as Map<String, dynamic>;
      final rawUsd = (raw['data'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (i) => i['symbol'] == 'USD',
          );

      final quotes = byCode((await provider.fetchRates()).valueOrNull!);

      expect(quotes.length, 21, reason: '22 symbols minus XDR');
      expect(quotes.containsKey('XDR'), isFalse);
      expect(quotes['USD']!.priceTry, d(rawUsd['buyRate'].toString()));
      expect(quotes['USD']!.changePercent, isNotNull);
      expect(quotes['USD']!.asOf, isNotNull);
      expect(quotes.values.every((q) => q.priceTry > d('0')), isTrue);
    },
  );

  test('/gold: 7 TRY instruments, XAUUSD skipped, buying used', () async {
    final quotes = byCode((await provider.fetchPrices()).valueOrNull!);

    expect(quotes.keys.toSet(), {
      'GRAM',
      'ATA',
      'CEYREK',
      'CUMHURIYET',
      'SILVER_GRAM',
      'TAM',
      'YARIM',
    });
    expect(quotes['GRAM']!.priceTry, d('6066.95'));
    expect(quotes['GRAM']!.changePercent, d('-2.79'));
    expect(
      quotes['SILVER_GRAM']!.instrument,
      (type: AssetType.silver, code: 'SILVER_GRAM'),
    );
  });

  test('/stocks: price and changePercent', () async {
    final quotes = byCode(
      (await provider.fetchQuotes(symbols: ['THYAO', 'ASELS'])).valueOrNull!,
    );

    expect(quotes['THYAO']!.priceTry, d('323.75'));
    expect(quotes['THYAO']!.changePercent, d('0.47'));
    expect(quotes['ASELS']!.priceTry, d('343.75'));
  });

  test('/kap: paged envelope, KAP link from short_description', () async {
    final items = (await provider.fetchDisclosures('THYAO')).valueOrNull!;

    expect(items, hasLength(5));
    expect(items.every((d) => d.symbol == 'THYAO'), isTrue);
    final first = items.first;
    expect(first.title, 'Şirket Genel Bilgi Formu');
    expect(first.summary, isNull, reason: 'empty summary');
    expect(first.headline, 'Şirket Genel Bilgi Formu');
    expect(first.url, 'https://www.kap.org.tr/tr/Bildirim/1697886');
    expect(first.publishedAt, DateTime.utc(2026, 11, 13, 7, 58));
    expect(items[1].headline, 'Ekim 2026 Trafik Sonuçları');
    expect(items[1].title, 'Özel Durum Açıklaması (Genel)');
  });

  test('quota headers sync the local counter', () async {
    await provider.fetchPrices();

    final usage = await quota.current();
    expect(usage.limit, 1000);
    expect(usage.used, 3);
  });
}
