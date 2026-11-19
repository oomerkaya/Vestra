import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/features/market/domain/entities/market_calendar.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
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

  group('isDue', () {
    // Monday 14:00 Istanbul: session open.
    final open = ist(2026, 11, 16, 14);
    // Monday 18:14 Istanbul: session closed.
    final evening = ist(2026, 11, 16, 18, 14);
    // Saturday noon.
    final weekend = ist(2026, 11, 21, 12);

    bool due(
      QuoteCategory category, {
      required DateTime now,
      Duration? sinceSuccess,
      Duration? sinceAttempt,
      bool manual = false,
      DateTime? backoffUntil,
    }) => RefreshPolicy.isDue(
      category: category,
      now: now,
      lastSuccess: sinceSuccess == null ? null : now.subtract(sinceSuccess),
      lastAttempt: sinceAttempt == null ? null : now.subtract(sinceAttempt),
      calendar: calendar,
      manual: manual,
      backoffUntil: backoffUntil,
    );

    test('FX, metals and stocks wait 60 minutes after an update', () {
      for (final c in QuoteCategory.values.where(
        (c) => c != QuoteCategory.funds,
      )) {
        expect(
          due(c, now: open, sinceSuccess: const Duration(minutes: 59)),
          isFalse,
        );
        expect(
          due(c, now: open, sinceSuccess: const Duration(minutes: 60)),
          isTrue,
        );
      }
    });

    test('funds update once per Istanbul day, any hour', () {
      // Last update Monday 09:00 Istanbul.
      final monday9 = ist(2026, 11, 16, 9);
      bool fundsDue(DateTime now) => RefreshPolicy.isDue(
        category: QuoteCategory.funds,
        now: now,
        lastSuccess: monday9,
        lastAttempt: null,
        calendar: calendar,
        manual: true,
      );

      expect(fundsDue(ist(2026, 11, 16, 23, 59)), isFalse, reason: 'same day');
      expect(fundsDue(ist(2026, 11, 17, 0, 1)), isTrue, reason: 'next day');
      expect(fundsDue(ist(2026, 11, 22, 3)), isTrue, reason: 'weekend ok');
    });

    test('next fund update is the next Istanbul midnight', () {
      expect(
        RefreshPolicy.nextUpdate(
          ist(2026, 11, 16, 14),
          category: QuoteCategory.funds,
        ),
        ist(2026, 11, 17, 0),
      );
    });

    test('manual refresh does NOT bypass the 60 minute rule', () {
      for (final c in QuoteCategory.values) {
        expect(
          due(
            c,
            now: open,
            sinceSuccess: const Duration(minutes: 5),
            manual: true,
          ),
          isFalse,
        );
      }
    });

    test('FX and metals update outside session hours and on weekends', () {
      for (final now in [evening, weekend]) {
        expect(due(QuoteCategory.fx, now: now), isTrue);
        expect(due(QuoteCategory.metals, now: now), isTrue);
      }
    });

    test('stocks never outside the session once fetched, not manually', () {
      for (final now in [evening, weekend, ist(2026, 11, 18, 12)]) {
        const old = Duration(hours: 5);
        expect(due(QuoteCategory.stocks, now: now, sinceSuccess: old), isFalse);
        expect(
          due(QuoteCategory.stocks, now: now, sinceSuccess: old, manual: true),
          isFalse,
        );
      }
    });

    test('first fetch of any category is allowed any time', () {
      for (final now in [open, evening, weekend]) {
        for (final c in QuoteCategory.values) {
          expect(due(c, now: now), isTrue, reason: '$c at $now');
        }
      }
    });

    test('first fetch still respects a failed attempt (auto)', () {
      expect(
        due(
          QuoteCategory.stocks,
          now: weekend,
          sinceAttempt: const Duration(minutes: 3),
        ),
        isFalse,
      );
    });

    test('after a failed attempt, auto waits 60 min, manual may retry', () {
      const failedAgo = Duration(minutes: 3);
      expect(
        due(QuoteCategory.fx, now: open, sinceAttempt: failedAgo),
        isFalse,
      );
      expect(
        due(QuoteCategory.fx, now: open, sinceAttempt: failedAgo, manual: true),
        isTrue,
      );
    });

    test('nothing while rate-limit backoff is active, even manually', () {
      expect(
        due(
          QuoteCategory.fx,
          now: open,
          manual: true,
          backoffUntil: open.add(const Duration(minutes: 1)),
        ),
        isFalse,
      );
    });

    test('nextUpdate is 60 minutes after the last success', () {
      expect(
        RefreshPolicy.nextUpdate(DateTime(2026, 11, 16, 18, 14)),
        DateTime(2026, 11, 16, 19, 14),
      );
      expect(RefreshPolicy.nextUpdate(null), isNull);
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
