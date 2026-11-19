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

class _FakeKap implements DisclosureRepository {
  _FakeKap(this.clock);

  final DateTime Function() clock;
  final Map<String, DateTime> fetched = {};
  final List<String> calls = [];
  Set<String>? kept;
  Failure? failWith;

  @override
  Stream<Result<List<KapDisclosure>>> watchAll() =>
      Stream.value(const Success([]));

  @override
  Future<DateTime?> lastFetchedAt(String symbol) async => fetched[symbol];

  @override
  Future<Result<int>> refresh(String symbol) async {
    calls.add(symbol);
    final f = failWith;
    if (f != null) return Err(f);
    fetched[symbol] = clock();
    return const Success(1);
  }

  @override
  Future<Result<void>> keepOnly(Set<String> symbols) async {
    kept = symbols;
    return const Success(null);
  }
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

  test('fetches the 5 most valuable held stocks, one request each', () async {
    final requested = await controller().refreshAuto();

    expect(requested, ['G', 'F', 'E', 'D', 'C']);
    expect(kap.calls, hasLength(5));
    expect(kap.kept, {'A', 'B', 'C', 'D', 'E', 'F', 'G'});
  });

  test('only once per day', () async {
    await controller().refreshAuto();
    now = ist(2026, 11, 19, 17);
    expect(await controller().refreshAuto(), isEmpty);

    now = ist(2026, 11, 20, 8, 30);
    expect(await controller().refreshAuto(), hasLength(5));
    expect(kap.calls, hasLength(10));
  });

  test('nothing automatic below 20 % of the quota', () async {
    used = 850;
    container.invalidate(quotaUsageProvider);

    expect(await controller().refreshAuto(), isEmpty);
    expect(kap.calls, isEmpty);
  });

  test('detail screen fetches a stock outside the top 5, once a day', () async {
    expect(await controller().ensureFresh('a'), isTrue);
    expect(await controller().ensureFresh('A'), isFalse);
    expect(kap.calls, ['A']);
  });

  test('stops after a missing key instead of trying every stock', () async {
    kap.failWith = const AuthFailure(missingKey: true);

    await controller().refreshAuto();

    expect(kap.calls, ['G']);
  });
}
