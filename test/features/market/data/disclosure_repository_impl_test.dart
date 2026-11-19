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

  /// Feed pages, page 0 = newest.
  final List<DisclosureFeedPage> pages = [];
  final List<String> calls = [];
  Failure? fail;
  int? failOnPage;

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

  @override
  Future<Result<DisclosureFeedPage>> fetchDisclosureFeed({
    int page = 0,
  }) async {
    calls.add('feed:$page');
    if (page == failOnPage) return const Err(NetworkFailure());
    return Success(
      page < pages.length
          ? pages[page]
          : const DisclosureFeedPage(items: [], isLast: true),
    );
  }
}

KapDisclosure _d(String id, String symbol, DateTime at, {String? url}) =>
    KapDisclosure(
      id: '$id:$symbol',
      symbol: symbol,
      title: 'Özel Durum Açıklaması (Genel)',
      summary: 'Konu $id',
      url: url,
      publishedAt: at,
    );

DisclosureFeedPage _page(List<KapDisclosure> items) =>
    DisclosureFeedPage(items: items, isLast: false);

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

  Future<List<KapDisclosure>> stored() async =>
      (await repository.watchAll().first).valueOrNull!;

  /// Records a previous feed read at [at] (empty feed, one request).
  Future<void> previousFeedAt(DateTime at) async {
    final saved = now;
    now = at;
    await repository.refreshFeed({'X'});
    now = saved;
    provider.calls.clear();
  }

  group('single stock', () {
    test('stores the disclosures and the fetch time', () async {
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
      expect((await stored()).map((d) => d.id), ['1:THYAO', '2:THYAO']);
      expect((await stored()).first.url, 'https://www.kap.org.tr/x');
      expect(await repository.lastFetchedAt('THYAO'), now);
      expect(await repository.lastFeedAt(), isNull);
    });

    test('a failure keeps stored data and the fetch time', () async {
      provider.bySymbol['THYAO'] = [
        _d('1', 'THYAO', DateTime.utc(2026, 11, 13)),
      ];
      await repository.refresh('THYAO');
      provider.fail = const NetworkFailure();
      final first = now;
      now = now.add(const Duration(days: 1));

      expect(await repository.refresh('THYAO'), isA<Err<int>>());
      expect(await stored(), hasLength(1));
      expect(await repository.lastFetchedAt('THYAO'), first);
    });
  });

  group('feed', () {
    test('first read: one page, only held stocks kept', () async {
      provider.pages.add(
        _page([
          _d('a', 'THYAO', DateTime.utc(2026, 11, 19, 8)),
          _d('b', 'GARAN', DateTime.utc(2026, 11, 19, 7)),
          _d('b', 'TGB', DateTime.utc(2026, 11, 19, 7)),
          _d('c', 'ASELS', DateTime.utc(2026, 11, 18, 9)),
        ]),
      );

      final result = await repository.refreshFeed({'THYAO', 'TGB'});

      expect(result.valueOrNull, 2);
      expect(provider.calls, ['feed:0'], reason: 'one request');
      expect((await stored()).map((d) => d.symbol), ['THYAO', 'TGB']);
      expect(await repository.lastFeedAt(), now);
    });

    test('reads older pages until the previous read is covered', () async {
      await previousFeedAt(DateTime.utc(2026, 11, 17, 12));
      provider.pages.addAll([
        _page([_d('1', 'THYAO', DateTime.utc(2026, 11, 18, 10))]),
        _page([_d('2', 'THYAO', DateTime.utc(2026, 11, 17, 8))]),
        _page([_d('3', 'THYAO', DateTime.utc(2026, 11, 16))]),
      ]);

      await repository.refreshFeed({'THYAO'});

      expect(provider.calls, ['feed:0', 'feed:1']);
      expect((await stored()).map((d) => d.id), ['1:THYAO', '2:THYAO']);
    });

    test('never more than 3 pages', () async {
      await previousFeedAt(DateTime.utc(2026, 11));
      for (var i = 0; i < 5; i++) {
        provider.pages.add(
          _page([_d('$i', 'THYAO', DateTime.utc(2026, 11, 18 - i))]),
        );
      }

      await repository.refreshFeed({'THYAO'});

      expect(provider.calls, ['feed:0', 'feed:1', 'feed:2']);
    });

    test('a failed page keeps earlier pages but not the feed time', () async {
      final previous = DateTime.utc(2026, 11, 17, 12);
      await previousFeedAt(previous);
      provider
        ..pages.add(_page([_d('1', 'THYAO', DateTime.utc(2026, 11, 18))]))
        ..failOnPage = 1;

      final result = await repository.refreshFeed({'THYAO'});

      expect(result, isA<Err<int>>());
      expect(await stored(), hasLength(1));
      expect(await repository.lastFeedAt(), previous);
    });
  });

  test('keepOnly drops sold stocks and disclosures over 30 days', () async {
    provider.bySymbol
      ..['THYAO'] = [
        _d('new', 'THYAO', DateTime.utc(2026, 11, 13)),
        _d('old', 'THYAO', DateTime.utc(2026, 10, 10)),
      ]
      ..['ASELS'] = [_d('a', 'ASELS', DateTime.utc(2026, 11, 12))];
    await repository.refresh('THYAO');
    await repository.refresh('ASELS');

    await repository.keepOnly({'THYAO'});

    expect((await stored()).map((d) => d.id), ['new:THYAO']);
    expect(await repository.lastFetchedAt('ASELS'), isNull);
    expect(await repository.lastFetchedAt('THYAO'), isNotNull);
  });

  test('seen time is stored and watched', () async {
    expect(await repository.watchSeenAt().first, isNull);

    await repository.markSeen(now);

    expect(await repository.watchSeenAt().first, now);
  });
}
