import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/repositories/disclosure_repository.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/portfolio/presentation/kap_refresh_controller.dart';

/// Counts feed requests; "fetches" at the test clock.
class _FakeKap implements DisclosureRepository {
  _FakeKap(this.clock);

  final DateTime Function() clock;
  DateTime? feedAt;
  int feeds = 0;
  int prunes = 0;
  Failure? failWith;

  @override
  Stream<Result<List<KapDisclosure>>> watchForSymbols(Set<String> symbols) =>
      Stream.value(const Success([]));

  @override
  Future<DateTime?> lastFeedAt() async => feedAt;

  @override
  Future<Result<int>> refreshFeed() async {
    feeds++;
    final f = failWith;
    if (f != null) return Err(f);
    feedAt = clock();
    return const Success(0);
  }

  @override
  Future<Result<void>> prune() async {
    prunes++;
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

void main() {
  late DateTime now;
  late _FakeKap kap;
  late int used;
  late ProviderContainer container;

  setUp(() {
    now = ist(2026, 11, 19, 9);
    kap = _FakeKap(() => now);
    used = 10;
    container =
        ProviderContainer(
            overrides: [
              autoRefreshEnabledProvider.overrideWithValue(false),
              disclosureRepositoryProvider.overrideWithValue(kap),
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

  test('one feed request a day, from 08:00', () async {
    expect(await controller().refreshDue(), isTrue);

    now = ist(2026, 11, 19, 17);
    expect(await controller().refreshDue(), isFalse, reason: 'same day');
    now = ist(2026, 11, 20, 7, 59);
    expect(await controller().refreshDue(), isFalse, reason: 'too early');
    now = ist(2026, 11, 20, 8);
    expect(await controller().refreshDue(), isTrue);

    expect(kap.feeds, 2);
    expect(kap.prunes, greaterThanOrEqualTo(4), reason: 'old ones dropped');
  });

  test('first launch fetches right away, even at night', () async {
    now = ist(2026, 11, 19, 2);

    expect(await controller().refreshDue(), isTrue);
  });

  test('runs above half of the quota; stops only when used up', () async {
    used = 900;
    container.invalidate(quotaUsageProvider);
    expect(await controller().refreshDue(), isTrue);

    now = ist(2026, 11, 20, 9);
    used = 1000;
    container.invalidate(quotaUsageProvider);
    expect(await controller().refreshDue(), isFalse);
    expect(kap.feeds, 1);
  });

  test('a failure waits an hour before the next try', () async {
    kap.failWith = const NetworkFailure();
    await controller().refreshDue();

    now = now.add(const Duration(minutes: 30));
    expect(await controller().refreshDue(), isFalse);
    now = now.add(const Duration(minutes: 30));
    expect(await controller().refreshDue(), isTrue);
    expect(kap.feeds, 2);
  });
}
