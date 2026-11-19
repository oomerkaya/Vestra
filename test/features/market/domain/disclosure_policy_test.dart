import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/services/disclosure_policy.dart';

import '../../../helpers/fixtures.dart';

/// Istanbul wall-clock time as an instant (Istanbul = UTC+3).
DateTime ist(int y, int m, int d, int h, [int min = 0]) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(hours: 3));

void main() {
  group('autoSymbols', () {
    test('the 5 most valuable stocks, unpriced last', () {
      final symbols = DisclosurePolicy.autoSymbols([
        (symbol: 'A', value: d('100')),
        (symbol: 'NOPRICE', value: null),
        (symbol: 'B', value: d('900')),
        (symbol: 'C', value: d('300')),
        (symbol: 'D', value: d('50')),
        (symbol: 'E', value: d('700')),
        (symbol: 'F', value: d('10')),
      ]);

      expect(symbols, ['B', 'E', 'C', 'A', 'D']);
    });

    test('unpriced stocks fill up the rest', () {
      expect(
        DisclosurePolicy.autoSymbols([
          (symbol: 'X', value: null),
          (symbol: 'A', value: d('1')),
          (symbol: 'Y', value: null),
        ]),
        ['A', 'X', 'Y'],
      );
    });
  });

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
      expect(
        DisclosurePolicy.isDue(
          now: now,
          lastFetched: monday9,
          lastAttempt: now.subtract(const Duration(minutes: 30)),
        ),
        isFalse,
      );
      expect(
        DisclosurePolicy.isDue(
          now: now,
          lastFetched: monday9,
          lastAttempt: now.subtract(const Duration(minutes: 60)),
        ),
        isTrue,
      );
    });
  });

  test('automatic fetching stops below 20 % of the quota', () {
    QuotaUsage used(int n) =>
        QuotaUsage(period: '2026-11', used: n, limit: 1000);

    expect(DisclosurePolicy.autoAllowed(used(800)), isTrue);
    expect(DisclosurePolicy.autoAllowed(used(801)), isFalse);
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
