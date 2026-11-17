import 'dart:math' as math;

import 'package:vestra/features/market/domain/entities/market_calendar.dart';

/// When prices are refreshed automatically. Pure and fully testable.
///
/// Rules (see CLAUDE.md / docs/faz-3-piyasa-verisi.md):
/// - Auto refresh only on weekdays 10:00-18:00 Europe/Istanbul, never on
///   closed days, until 12:30 on half days.
/// - At most every [autoInterval] (30 min, chosen to protect the
///   1,000 requests/month Bürküt quota).
/// - If nothing is cached yet, one refresh is allowed at any time so a
///   first start on a weekend still shows prices.
/// - Never while backing off after a rate limit or network failure.
/// - An exhausted Bürküt quota does not stop refreshes: no Bürküt request
///   is sent then, and FX still updates from the free fallback.
abstract final class RefreshPolicy {
  static const Duration autoInterval = Duration(minutes: 30);
  static const Duration maxBackoff = Duration(minutes: 30);

  /// Turkey has used UTC+3 all year since 2016 (no DST).
  static const Duration istanbulOffset = Duration(hours: 3);

  static const int _openMinute = 10 * 60;
  static const int _closeMinute = 18 * 60;
  static const int _halfDayCloseMinute = 12 * 60 + 30;

  /// Istanbul wall-clock time as a UTC-flagged [DateTime] (fields are local).
  static DateTime toIstanbul(DateTime instant) =>
      instant.toUtc().add(istanbulOffset);

  static bool isSessionOpen(DateTime now, MarketCalendar calendar) {
    final local = toIstanbul(now);
    if (local.weekday == DateTime.saturday ||
        local.weekday == DateTime.sunday) {
      return false;
    }
    if (calendar.isClosed(local)) return false;
    final minute = local.hour * 60 + local.minute;
    final close = calendar.isHalfDay(local)
        ? _halfDayCloseMinute
        : _closeMinute;
    return minute >= _openMinute && minute < close;
  }

  static bool shouldAutoRefresh({
    required DateTime now,
    required DateTime? lastFetchedAt,
    required MarketCalendar calendar,
    DateTime? backoffUntil,
  }) {
    if (backoffUntil != null && now.isBefore(backoffUntil)) return false;
    if (lastFetchedAt == null) return true;
    if (!isSessionOpen(now, calendar)) return false;
    return now.difference(lastFetchedAt) >= autoInterval;
  }

  /// Exponential backoff: 1, 2, 4, 8, 16, 30, 30 ... minutes.
  /// A server-provided `Retry-After` wins if it is longer.
  static Duration backoff(int consecutiveFailures, {Duration? retryAfter}) {
    final exponent = math.max(0, math.min(consecutiveFailures - 1, 10));
    final computed = Duration(minutes: 1 << exponent);
    final capped = computed > maxBackoff ? maxBackoff : computed;
    if (retryAfter != null && retryAfter > capped) return retryAfter;
    return capped;
  }
}
