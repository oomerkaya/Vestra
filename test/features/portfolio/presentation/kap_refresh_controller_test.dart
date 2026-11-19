import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/repositories/disclosure_repository.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/portfolio/domain/entities/asset.dart';
import 'package:vestra/features/portfolio/domain/entities/holding.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/portfolio/presentation/kap_refresh_controller.dart';

import '../../../helpers/fixtures.dart';

/// Records every request; "fetches" at the test clock.
class _FakeKap implements DisclosureRepository {
  _FakeKap(this.clock);

  final DateTime Function() clock;
  final Map<String, DateTime> fetched = {};
  DateTime? feedAt;
  final List<String> calls = [];
  Set<String>? kept;
  Set<String>? feedHeld;
  Failure? failWith;

  @override
  Stream<Result<List<KapDisclosure>>> watchAll() =>
      Stream.value(const Success([]));

  @override
  Future<DateTime?> lastFetchedAt(String symbol) async => fetched[symbol];

  @override
  Future<DateTime?> lastFeedAt() async => feedAt;

  @override
  Future<Result<int>> refresh(String symbol) async {
    calls.add(symbol);
    final f = failWith;
    if (f != null) return Err(f);
    fetched[symbol] = clock();
    return const Success(1);
  }

  @override
  Future<Result<int>> refreshFeed(Set<String> held) async {
    calls.add('feed');
    feedHeld = held;
    final f = failWith;
    if (f != null) return Err(f);
    feedAt = clock();
    return const Success(0);
  }

  @override
  Future<Result<void>> keepOnly(Set<String> symbols) async {
    kept = symbols;
    return const Success(null);
  }

  @override
  Stream<DateTime?> watchSeenAt() => Stream.value(null);

  @override
  Future<Result<void>> markSeen(DateTime at) async => const Success(null);
}

/// Istanbul wall-clock time as an instant (Istanbul = UTC+3).
DateTime ist(int y, int m, int d, int h, [int min = 0]) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(hours: 3));

Holding _holding(int id, AssetType type, String code, String qty) => Holding(
  asset: Asset(id: id, type: type, code: code, name: code),
  quantity: d(qty),
  transactionCount: 1,
);

Quote _quote(AssetType type, String code, String price) => Quote(
  instrument: (type: type, code: code),
  priceTry: d(price),
  source: QuoteSource.burkut,
  fetchedAt: DateTime.utc(2026, 11, 19),
);

void main() {
  late DateTime now;
  late _FakeKap kap;
  late int used;
  late ProviderContainer container;

  // Values: G 6000, F 5000, E 4000, D 3000, C 2000, B 1000, A unpriced;
  // USD is not a stock.
  final holdings = [
    _holding(1, AssetType.stock, 'A', '10'),
    _holding(2, AssetType.stock, 'B', '10'),
    _holding(3, AssetType.stock, 'C', '20'),
    _holding(4, AssetType.stock, 'D', '30'),
    _holding(5, AssetType.stock, 'E', '40'),
    _holding(6, AssetType.stock, 'F', '50'),
    _holding(7, AssetType.stock, 'G', '60'),
    _holding(8, AssetType.currency, 'USD', '1000'),
  ];
  final quotes = [
    for (final c in ['B', 'C', 'D', 'E', 'F', 'G'])
      _quote(AssetType.stock, c, '100'),
    _quote(AssetType.currency, 'USD', '42'),
  ];
  const allHeld = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};

  setUp(() {
    now = ist(2026, 11, 19, 9);
    kap = _FakeKap(() => now);
    used = 10;
    container =
        ProviderContainer(
            overrides: [
              autoRefreshEnabledProvider.overrideWithValue(false),
              disclosureRepositoryProvider.overrideWithValue(kap),
              holdingsProvider.overrideWith((ref) => Stream.value(holdings)),
              quotesProvider.overrideWith((ref) => Stream.value(quotes)),
              quotaUsageProvider.overrideWith(
                (ref) async =>
                    QuotaUsage(period: '2026-11', used: used, limit: 1000),
              ),
            ],
          )
          // Listened like in the app (VestraApp keeps it alive).
          ..listen(kapRefreshControllerProvider, (_, _) {})
          ..read(kapRefreshControllerProvider.notifier).clock = () => now;
  });
  tearDown(() => container.dispose());

  KapRefreshController controller() =>
      container.read(kapRefreshControllerProvider.notifier);

  void setUsed(int value) {
    used = value;
    container.invalidate(quotaUsageProvider);
  }

  test('first day: history for the top 5, then one feed for all', () async {
    final started = await controller().refreshAuto();

    expect(kap.calls, ['G', 'F', 'E', 'D', 'C', 'feed']);
    expect(started, 6);
    expect(kap.feedHeld, allHeld, reason: 'feed covers every held stock');
    expect(kap.kept, allHeld);
  });

  test('later days: only the feed, one request', () async {
    await controller().refreshAuto();
    kap.calls.clear();

    now = ist(2026, 11, 19, 17);
    expect(await controller().refreshAuto(), 0, reason: 'same day');

    now = ist(2026, 11, 20, 7, 59);
    expect(await controller().refreshAuto(), 0, reason: 'before 08:00');

    now = ist(2026, 11, 20, 8);
    expect(await controller().refreshAuto(), 1);
    expect(kap.calls, ['feed']);
  });

  test('a stock that enters the top 5 gets its history once', () async {
    await controller().refreshAuto();
    kap.calls.clear();
    kap.fetched.remove('C'); // e.g. C was bought later

    now = ist(2026, 11, 19, 12);
    await controller().refreshAuto();

    expect(kap.calls, ['C']);
  });

  test('nothing automatic once half of the quota is used', () async {
    setUsed(500);

    expect(await controller().refreshAuto(), 0);
    expect(kap.calls, isEmpty);
  });

  group('detail screen', () {
    test('no request while automatic fetching runs', () async {
      expect(await controller().ensureFresh('A'), isFalse);
      expect(kap.calls, isEmpty);
    });

    test('after half the quota: fetches once a day', () async {
      setUsed(600);

      expect(await controller().ensureFresh('a'), isTrue);
      expect(await controller().ensureFresh('A'), isFalse);
      expect(kap.calls, ['A']);
    });

    test('after half the quota: nothing if the feed ran today', () async {
      await controller().refreshAuto();
      kap.calls.clear();
      setUsed(600);

      expect(await controller().ensureFresh('A'), isFalse);
      expect(kap.calls, isEmpty);
    });
  });

  test('stops after a missing key instead of trying every stock', () async {
    kap.failWith = const AuthFailure(missingKey: true);

    await controller().refreshAuto();

    expect(kap.calls, ['G']);
  });
}
