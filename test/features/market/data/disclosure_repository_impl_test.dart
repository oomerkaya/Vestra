import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/data/datasources/kap_disclosure_local_data_source.dart';
import 'package:vestra/features/market/data/repositories/disclosure_repository_impl.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';

import '../../../helpers/test_database.dart';

class _FakeProvider implements DisclosureProvider {
  final Map<String, List<KapDisclosure>> bySymbol = {};
  final List<String> calls = [];
  Failure? fail;

  @override
  Future<Result<List<KapDisclosure>>> fetchDisclosures(
    String symbol, {
    int limit = 5,
  }) async {
    calls.add(symbol);
    final f = fail;
    if (f != null) return Err(f);
    return Success((bySymbol[symbol] ?? const []).take(limit).toList());
  }
}

KapDisclosure _d(String id, String symbol, DateTime at, {String? url}) =>
    KapDisclosure(
      id: id,
      symbol: symbol,
      title: 'Özel Durum Açıklaması (Genel)',
      summary: 'Konu $id',
      url: url,
      publishedAt: at,
    );

void main() {
  late AppDatabase db;
  late _FakeProvider provider;
  late DisclosureRepositoryImpl repository;
  final now = DateTime.utc(2026, 11, 19, 9);

  setUp(() {
    db = createTestDatabase();
    provider = _FakeProvider();
    repository = DisclosureRepositoryImpl(
      provider: provider,
      local: KapDisclosureLocalDataSource(db),
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  Future<List<KapDisclosure>> stored() async =>
      (await repository.watchAll().first).valueOrNull!;

  test('refresh stores the disclosures and the fetch time', () async {
    provider.bySymbol['THYAO'] = [
      _d(
        '1',
        'THYAO',
        DateTime.utc(2026, 11, 13),
        url: 'https://www.kap.org.tr/x',
      ),
      _d('2', 'THYAO', DateTime.utc(2026, 11, 9)),
    ];

    final result = await repository.refresh('thyao');

    expect(result.valueOrNull, 2);
    expect(provider.calls, ['THYAO']);
    expect((await stored()).map((d) => d.id), ['1', '2']);
    expect((await stored()).first.url, 'https://www.kap.org.tr/x');
    expect(await repository.lastFetchedAt('THYAO'), now);
  });

  test('a new fetch replaces the old disclosures of that stock only', () async {
    provider.bySymbol
      ..['THYAO'] = [_d('old', 'THYAO', DateTime.utc(2026, 11, 3))]
      ..['ASELS'] = [_d('a1', 'ASELS', DateTime.utc(2026, 11, 2))];
    await repository.refresh('THYAO');
    await repository.refresh('ASELS');

    provider.bySymbol['THYAO'] = [
      _d('new', 'THYAO', DateTime.utc(2026, 11, 18)),
    ];
    await repository.refresh('THYAO');

    expect((await stored()).map((d) => d.id), ['new', 'a1']);
  });

  test('a failure keeps the stored disclosures and fetch time', () async {
    provider.bySymbol['THYAO'] = [_d('1', 'THYAO', DateTime.utc(2026, 11, 13))];
    await repository.refresh('THYAO');
    provider.fail = const NetworkFailure();

    final result = await repository.refresh('THYAO');

    expect(result, isA<Err<int>>());
    expect(await stored(), hasLength(1));
    expect(await repository.lastFetchedAt('THYAO'), now);
  });

  test('keepOnly drops stocks that are no longer held', () async {
    provider.bySymbol
      ..['THYAO'] = [_d('t', 'THYAO', DateTime.utc(2026, 11, 13))]
      ..['ASELS'] = [_d('a', 'ASELS', DateTime.utc(2026, 11, 12))];
    await repository.refresh('THYAO');
    await repository.refresh('ASELS');

    await repository.keepOnly({'THYAO'});

    expect((await stored()).map((d) => d.symbol), ['THYAO']);
    expect(await repository.lastFetchedAt('ASELS'), isNull);
    expect(await repository.lastFetchedAt('THYAO'), isNotNull);
  });
}
