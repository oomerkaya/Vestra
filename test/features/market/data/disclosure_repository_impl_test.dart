import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/features/market/data/datasources/kap_disclosure_local_data_source.dart';
import 'package:capira/features/market/data/repositories/disclosure_repository_impl.dart';
import 'package:capira/features/market/domain/entities/kap_disclosure.dart';
import 'package:capira/features/market/domain/providers/price_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

class _FakeProvider implements DisclosureProvider {
  List<KapDisclosure> feed = [];
  int calls = 0;
  Failure? fail;

  @override
  Future<Result<List<KapDisclosure>>> fetchDisclosureFeed() async {
    calls++;
    final f = fail;
    return f != null ? Err(f) : Success(feed);
  }
}

KapDisclosure _d(String id, String symbol, DateTime at) => KapDisclosure(
  id: '$id:$symbol',
  symbol: symbol,
  title: 'Özel Durum Açıklaması (Genel)',
  summary: 'Konu $id',
  url: 'https://www.kap.org.tr/tr/Bildirim/$id',
  publishedAt: at,
);

void main() {
  late AppDatabase db;
  late _FakeProvider provider;
  late DisclosureRepositoryImpl repository;
  late DateTime now;

  setUp(() {
    now = DateTime.utc(2026, 11, 19, 9);
    db = createTestDatabase();
    provider = _FakeProvider();
    repository = DisclosureRepositoryImpl(
      provider: provider,
      local: KapDisclosureLocalDataSource(db),
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  Future<List<KapDisclosure>> stored(Set<String> symbols) async =>
      (await repository.watchForSymbols(symbols).first).valueOrNull!;

  test('one request stores every company, not only held ones', () async {
    provider.feed = [
      _d('a', 'THYAO', DateTime.utc(2026, 11, 19, 8)),
      _d('b', 'GARAN', DateTime.utc(2026, 11, 19, 7)),
      _d('b', 'TGB', DateTime.utc(2026, 11, 19, 7)),
    ];

    final result = await repository.refreshFeed();

    expect(result.valueOrNull, 3);
    expect(provider.calls, 1);
    expect(await repository.lastFeedAt(), now);
    // A stock bought later shows what was stored before.
    expect((await stored({'GARAN'})).single.id, 'b:GARAN');
    expect((await stored({'thyao', 'TGB'})).map((d) => d.symbol), [
      'THYAO',
      'TGB',
    ]);
  });

  test('daily feeds add up; the same disclosure is stored once', () async {
    provider.feed = [_d('1', 'THYAO', DateTime.utc(2026, 11, 18, 10))];
    await repository.refreshFeed();
    provider.feed = [
      _d('2', 'THYAO', DateTime.utc(2026, 11, 19, 8)),
      _d('1', 'THYAO', DateTime.utc(2026, 11, 18, 10)),
    ];
    await repository.refreshFeed();

    expect((await stored({'THYAO'})).map((d) => d.id), ['2:THYAO', '1:THYAO']);
  });

  test('a failure keeps stored data and the last feed time', () async {
    provider.feed = [_d('1', 'THYAO', DateTime.utc(2026, 11, 18))];
    await repository.refreshFeed();
    final first = now;
    now = now.add(const Duration(days: 1));
    provider.fail = const NetworkFailure();

    expect(await repository.refreshFeed(), isA<Err<int>>());
    expect(await stored({'THYAO'}), hasLength(1));
    expect(await repository.lastFeedAt(), first);
  });

  test('prune deletes disclosures older than 30 days', () async {
    provider.feed = [
      _d('new', 'THYAO', DateTime.utc(2026, 11, 2)),
      _d('old', 'THYAO', DateTime.utc(2026, 10, 19)),
    ];
    await repository.refreshFeed();

    await repository.prune();

    expect((await stored({'THYAO'})).map((d) => d.id), ['new:THYAO']);
  });

  test('seen time is stored and watched', () async {
    expect(await repository.watchSeenAt().first, isNull);

    await repository.markSeen(now);

    expect(await repository.watchSeenAt().first, now);
  });
}
