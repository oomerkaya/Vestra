import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/services/disclosure_policy.dart';

/// Istanbul wall-clock time as an instant (Istanbul = UTC+3).
DateTime ist(int y, int m, int d, int h, [int min = 0]) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(hours: 3));

void main() {
  group('isDue', () {
    final monday9 = ist(2026, 11, 16, 9);

    test('never fetched: any time, even at night', () {
      expect(
        DisclosurePolicy.isDue(now: ist(2026, 11, 16, 2), lastFetched: null),
        isTrue,
      );
    });

    test('once per Istanbul day, from 08:00', () {
      bool due(DateTime now) =>
          DisclosurePolicy.isDue(now: now, lastFetched: monday9);

      expect(due(ist(2026, 11, 16, 23)), isFalse, reason: 'same day');
      expect(due(ist(2026, 11, 17, 7, 59)), isFalse, reason: 'too early');
      expect(due(ist(2026, 11, 17, 8)), isTrue);
      expect(due(ist(2026, 11, 21, 12)), isTrue, reason: 'weekend too');
    });

    test('a failed attempt waits an hour', () {
      final now = ist(2026, 11, 17, 9);
      bool due(int minutesAgo) => DisclosurePolicy.isDue(
        now: now,
        lastFetched: monday9,
        lastAttempt: now.subtract(Duration(minutes: minutesAgo)),
      );

      expect(due(30), isFalse);
      expect(due(60), isTrue);
    });
  });

  test('fetching stops once half of the quota is used', () {
    QuotaUsage used(int n) =>
        QuotaUsage(period: '2026-11', used: n, limit: 1000);

    expect(DisclosurePolicy.autoAllowed(used(499)), isTrue);
    expect(DisclosurePolicy.autoAllowed(used(500)), isFalse);
    expect(
      DisclosurePolicy.autoAllowed(
        const QuotaUsage(
          period: '2026-11',
          used: 0,
          limit: 1000,
          exhaustedByServer: true,
        ),
      ),
      isFalse,
    );
  });
}
