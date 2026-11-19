import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/domain/instrument.dart';
import 'package:capira/features/market/data/datasources/burkut_remote_data_source.dart';
import 'package:capira/features/market/data/datasources/quota_local_data_source.dart';
import 'package:capira/features/market/data/providers/burkut_price_provider.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final path = options.path == '/kap' ? '/kap_feed' : options.path;
    final name = path.replaceAll('/', '');
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

  test(
    '/kap feed: all companies, multi-symbol split, notices skipped',
    () async {
      final items = (await provider.fetchDisclosureFeed()).valueOrNull!;

      expect(items.every((d) => d.symbol.isNotEmpty), isTrue);
      expect(items.any((d) => d.symbol.contains(',')), isFalse);
      // "GARAN, TGB" appears under both companies, ids unique per company.
      final garan = items.where((d) => d.symbol == 'GARAN').toList();
      final tgb = items.where((d) => d.symbol == 'TGB').toList();
      expect(garan, isNotEmpty);
      expect(tgb.length, garan.length);
      expect(items.map((d) => d.id).toSet(), hasLength(items.length));
      expect(
        items.every(
          (d) => d.url == null || d.url!.startsWith('https://www.kap.org.tr/'),
        ),
        isTrue,
      );
      expect(items.first.publishedAt, DateTime.utc(2026, 11, 19, 17, 22, 16));
    },
  );

  test('/quota: parsed, costs nothing locally', () async {
    final status = (await provider.fetchQuotaStatus()).valueOrNull!;

    expect(status.limit, 1000);
    expect(status.used, 49);
    expect(status.remaining, 951);
    expect(status.resetAt, DateTime.utc(2026, 12));
    expect((await quota.current()).used, 0, reason: 'not counted');

    final synced = await quota.syncStatus(status);
    expect(synced.used, 49);
    expect(synced.resetAt, DateTime.utc(2026, 12));
    expect((await quota.current()).resetAt, DateTime.utc(2026, 12));
  });

  test('quota headers sync the local counter', () async {
    await provider.fetchPrices();

    final usage = await quota.current();
    expect(usage.limit, 1000);
    expect(usage.used, 3);
  });
}
