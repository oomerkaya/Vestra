import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/market_calendar.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/repositories/market_repository.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/market/presentation/price_refresh_controller.dart';

import '../../../helpers/fixtures.dart';

/// In-memory market: `refresh` "fetches" the requested categories at the
/// test clock and records every call, i.e. every request batch.
class _FakeMarket implements MarketRepository {
  _FakeMarket(this.clock);

  DateTime Function() clock;
  final List<Set<QuoteCategory>> calls = [];
  final List<Set<String>> stockCalls = [];
  final Set<String> unknownSymbols = {};
  final List<Quote> _quotes = [];
  final _controller = StreamController<Result<List<Quote>>>.broadcast();
  Failure? failNext;

  @override
  Stream<Result<List<Quote>>> watchQuotes() async* {
    yield Success(List.of(_quotes));
    yield* _controller.stream;
  }

  @override
  Future<Result<RefreshReport>> refresh({
    required Set<QuoteCategory> categories,
    required Set<String> stockSymbols,
  }) async {
    calls.add(categories);
    if (categories.contains(QuoteCategory.stocks)) {
      stockCalls.add(stockSymbols);
    }
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      return Success(
        RefreshReport(
          updated: 0,
          failures: {for (final c in categories) c: failure},
        ),
      );
    }
    final now = clock();
    final fresh = <Quote>[
      if (categories.contains(QuoteCategory.fx))
        _q(AssetType.currency, 'USD', now),
      if (categories.contains(QuoteCategory.metals))
        _q(AssetType.gold, 'GRAM', now),
      if (categories.contains(QuoteCategory.stocks))
        for (final s in stockSymbols)
          if (!unknownSymbols.contains(s)) _q(AssetType.stock, s, now),
    ];
    _quotes
      ..removeWhere((q) => fresh.any((f) => f.instrument == q.instrument))
      ..addAll(fresh);
    _controller.add(Success(List.of(_quotes)));
    return Success(RefreshReport(updated: fresh.length, failures: const {}));
  }

  @override
  Future<Result<QuotaUsage>> quotaUsage() async => const Success(
    QuotaUsage(period: '2026-11', used: 0, limit: 1000),
  );

  static Quote _q(AssetType type, String code, DateTime at) => Quote(
    instrument: (type: type, code: code),
    priceTry: d('1'),
    source: QuoteSource.burkut,
    fetchedAt: at,
  );
}

/// Istanbul wall-clock time as an instant (Istanbul = UTC+3).
DateTime ist(int y, int m, int d, int h, [int min = 0]) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(hours: 3));

void main() {
  late DateTime now;
  late _FakeMarket market;
  late ProviderContainer container;

  ProviderContainer build({Set<String> held = const {'THYAO'}}) {
    // Listeners keep the stream providers alive like the UI does.
    return ProviderContainer(
        overrides: [
          autoRefreshEnabledProvider.overrideWithValue(false),
          marketRepositoryProvider.overrideWithValue(market),
          heldStockSymbolsProvider.overrideWith((ref) => Stream.value(held)),
          marketCalendarProvider.overrideWith(
            (ref) async => MarketCalendar.empty,
          ),
        ],
      )
      ..listen(quotesProvider, (_, _) {})
      ..listen(heldStockSymbolsProvider, (_, _) {})
      ..read(priceRefreshControllerProvider.notifier).clock = () => now;
  }

  setUp(() {
    now = ist(2026, 11, 16, 14); // Monday, session open
    market = _FakeMarket(() => now);
    container = build();
  });
  tearDown(() => container.dispose());

  PriceRefreshController controller() =>
      container.read(priceRefreshControllerProvider.notifier);

  test('first refresh fetches all three categories', () async {
    final requested = await controller().refreshDue(manual: true);

    expect(requested, QuoteCategory.values.toSet());
    expect(market.calls, hasLength(1));
  });

  test('pulling again within 30 minutes sends no request', () async {
    await controller().refreshDue(manual: true);

    now = now.add(const Duration(minutes: 10));
    final second = await controller().refreshDue(manual: true);
    now = now.add(const Duration(minutes: 19));
    final third = await controller().refreshDue(manual: true);

    expect(second, isEmpty);
    expect(third, isEmpty);
    expect(market.calls, hasLength(1), reason: 'no extra quota used');
  });

  test('after 30 minutes the categories are fetched again', () async {
    await controller().refreshDue(manual: true);

    now = now.add(const Duration(minutes: 30));
    final again = await controller().refreshDue();

    expect(again, QuoteCategory.values.toSet());
    expect(market.calls, hasLength(2));
  });

  test('after 18:00 only FX and metals are fetched, never stocks', () async {
    await controller().refreshDue(); // 14:00, THYAO gets a price
    now = ist(2026, 11, 16, 18, 14);

    final requested = await controller().refreshDue(manual: true);

    expect(requested, {QuoteCategory.fx, QuoteCategory.metals});
  });

  test('on a weekend FX and metals still update every 30 minutes', () async {
    await controller().refreshDue(); // Monday 14:00, THYAO gets a price
    market.calls.clear();
    now = ist(2026, 11, 21, 11);
    await controller().refreshDue();

    now = now.add(const Duration(minutes: 31));
    final requested = await controller().refreshDue();

    expect(requested, {QuoteCategory.fx, QuoteCategory.metals});
    expect(
      market.calls.every((c) => !c.contains(QuoteCategory.stocks)),
      isTrue,
    );
  });

  test('categories keep their own schedule', () async {
    // Session: everything at 14:00. Evening: FX + metals at 18:14.
    await controller().refreshDue();
    now = ist(2026, 11, 16, 18, 14);
    expect(await controller().refreshDue(), {
      QuoteCategory.fx,
      QuoteCategory.metals,
    });

    // Next morning 10:05: stocks due (session), FX/metals due (>30 min).
    now = ist(2026, 11, 17, 10, 5);
    expect(await controller().refreshDue(), QuoteCategory.values.toSet());

    // 10:20: nothing due for anyone.
    now = ist(2026, 11, 17, 10, 20);
    expect(await controller().refreshDue(manual: true), isEmpty);
  });

  test('no held stocks: stocks are never requested', () async {
    container.dispose();
    container = build(held: const {});

    final requested = await controller().refreshDue(manual: true);

    expect(requested, {QuoteCategory.fx, QuoteCategory.metals});
  });

  test('a failed category: auto waits, manual may retry', () async {
    market.failNext = const NetworkFailure();
    await controller().refreshDue();

    now = now.add(const Duration(minutes: 2));
    expect(await controller().refreshDue(), isEmpty);
    expect(
      await controller().refreshDue(manual: true),
      QuoteCategory.values.toSet(),
    );
  });

  test('failures are tracked per category', () async {
    market.failNext = const NetworkFailure();
    await controller().refreshDue();

    final state = container.read(priceRefreshControllerProvider);
    expect(state.failures.keys.toSet(), QuoteCategory.values.toSet());

    now = now.add(const Duration(minutes: 1));
    await controller().refreshDue(manual: true);
    expect(container.read(priceRefreshControllerProvider).failures, isEmpty);
  });

  group('stock added while the session is closed', () {
    Future<void> holdThyaoFetchedAt(DateTime at) async {
      now = at;
      await controller().refreshDue();
      container.dispose();
    }

    test('only the new stock is fetched, once', () async {
      // THYAO priced during the session.
      await holdThyaoFetchedAt(ist(2026, 11, 16, 14));

      // 21:00: user adds ASELS (no price yet).
      now = ist(2026, 11, 16, 21);
      container = build(held: const {'THYAO', 'ASELS'});
      final requested = await controller().refreshDue();

      expect(requested, contains(QuoteCategory.stocks));
      expect(market.stockCalls.last, {'ASELS'}, reason: 'THYAO not updated');

      // 21:05: nothing more for stocks (ASELS now has a price).
      now = ist(2026, 11, 16, 21, 5);
      expect(
        await controller().refreshDue(manual: true),
        isNot(contains(QuoteCategory.stocks)),
      );
    });

    test('next session: all held stocks update again', () async {
      await holdThyaoFetchedAt(ist(2026, 11, 16, 14));
      now = ist(2026, 11, 16, 21);
      container = build(held: const {'THYAO', 'ASELS'});
      await controller().refreshDue();

      // Next morning 10:01: THYAO is old -> regular update for both.
      now = ist(2026, 11, 17, 10, 1);
      final requested = await controller().refreshDue();

      expect(requested, contains(QuoteCategory.stocks));
      expect(market.stockCalls.last, {'THYAO', 'ASELS'});
    });

    test(
      'a symbol that returns no price is not retried every minute',
      () async {
        now = ist(2026, 11, 16, 21);
        container.dispose();
        container = build(held: const {'XXXX'});
        market.unknownSymbols.add('XXXX');

        await controller().refreshDue();
        now = now.add(const Duration(minutes: 1));
        await controller().refreshDue();

        expect(market.stockCalls, hasLength(1));
      },
    );
  });
}
