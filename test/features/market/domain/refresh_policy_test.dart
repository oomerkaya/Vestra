import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/features/market/domain/entities/market_calendar.dart';
import 'package:vestra/features/market/domain/services/refresh_policy.dart';

/// Istanbul wall-clock time expressed as a UTC instant (Istanbul = UTC+3).
DateTime ist(int y, int m, int d, int h, [int min = 0]) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(hours: 3));

void main() {
  // 2026-11-16 is a Monday.
  final calendar = MarketCalendar(
    closedDays: [DateTime(2026, 11, 18)],
    halfDays: [DateTime(2026, 11, 19)],
  );

  group('isSessionOpen', () {
    test('open on a weekday between 10:00 and 18:00 Istanbul', () {
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 16, 10), calendar),
        isTrue,
      );
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 16, 17, 59), calendar),
        isTrue,
      );
    });

    test('closed before 10:00 and from 18:00', () {
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 16, 9, 59), calendar),
        isFalse,
      );
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 16, 18), calendar),
        isFalse,
      );
    });

    test('uses Istanbul time, not device time', () {
      // 07:30 UTC = 10:30 Istanbul.
      expect(
        RefreshPolicy.isSessionOpen(
          DateTime.utc(2026, 11, 16, 7, 30),
          calendar,
        ),
        isTrue,
      );
    });

    test('closed on weekends', () {
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 21, 12), calendar),
        isFalse,
      );
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 22, 12), calendar),
        isFalse,
      );
    });

    test('closed on holidays from the calendar', () {
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 18, 12), calendar),
        isFalse,
      );
    });

    test('half days close at 12:30', () {
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 19, 12, 29), calendar),
        isTrue,
      );
      expect(
        RefreshPolicy.isSessionOpen(ist(2026, 11, 19, 12, 30), calendar),
        isFalse,
      );
    });
  });

  group('shouldAutoRefresh', () {
    final now = ist(2026, 11, 16, 14);

    test('always when nothing is cached, even outside the session', () {
      expect(
        RefreshPolicy.shouldAutoRefresh(
          now: ist(2026, 11, 22, 3),
          lastFetchedAt: null,
          calendar: calendar,
        ),
        isTrue,
      );
    });

    test('only after the 30 minute interval', () {
      bool at(Duration ago) => RefreshPolicy.shouldAutoRefresh(
        now: now,
        lastFetchedAt: now.subtract(ago),
        calendar: calendar,
      );
      expect(at(const Duration(minutes: 29)), isFalse);
      expect(at(const Duration(minutes: 30)), isTrue);
    });

    test('never outside the session when a cache exists', () {
      expect(
        RefreshPolicy.shouldAutoRefresh(
          now: ist(2026, 11, 16, 20),
          lastFetchedAt: ist(2026, 11, 16, 12),
          calendar: calendar,
        ),
        isFalse,
      );
    });

    test('not while backing off', () {
      expect(
        RefreshPolicy.shouldAutoRefresh(
          now: now,
          lastFetchedAt: null,
          calendar: calendar,
          backoffUntil: now.add(const Duration(minutes: 1)),
        ),
        isFalse,
      );
    });
  });

  test('backoff doubles up to 30 minutes and respects Retry-After', () {
    expect(
      [for (var i = 1; i <= 7; i++) RefreshPolicy.backoff(i).inMinutes],
      [1, 2, 4, 8, 16, 30, 30],
    );
    expect(
      RefreshPolicy.backoff(1, retryAfter: const Duration(minutes: 5)),
      const Duration(minutes: 5),
    );
    expect(
      RefreshPolicy.backoff(5, retryAfter: const Duration(seconds: 10)),
      const Duration(minutes: 16),
    );
  });

  test('calendar parses the asset JSON format', () {
    final parsed = MarketCalendar.fromJson({
      'closed': ['2027-01-01'],
      'half_days': ['2027-10-28'],
    });
    expect(parsed.isClosed(DateTime(2027)), isTrue);
    expect(parsed.isHalfDay(DateTime(2027, 10, 28)), isTrue);
    expect(parsed.isClosed(DateTime(2027, 1, 2)), isFalse);
  });
}
