import 'dart:math' as math;

import 'package:vestra/features/market/domain/entities/market_calendar.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';

/// When each price category may be fetched. Pure and fully testable.
///
/// Rules (CLAUDE.md, docs/faz-3-piyasa-verisi.md "Kategori bazlı
/// yenileme"):
/// - Every category is fetched at most every [interval] (30 min) after its
///   last successful update. Manual refresh (pull-to-refresh) follows the
///   same rule; it never forces a request.
/// - FX and metals: any day, any time (while the app is open).
/// - Stocks: only during the BIST session, weekdays 10:00-18:00
///   Europe/Istanbul, until 12:30 on half days, never on holidays.
/// - Exception: a held stock with **no cached price at all** (typically just
///   added) is fetched right away, even outside the session, so it never
///   shows "no price". Only those symbols are requested; the other stocks
///   still wait for the session ([isMissingStocksDue]).
/// - After a failed attempt, automatic retries wait [interval] too; a
///   manual refresh may retry right away (unless rate limited).
abstract final class RefreshPolicy {
  static const Duration interval = Duration(minutes: 30);
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

  /// Whether [category] is due for its regular update.
  ///
  /// [lastSuccess]: newest cached price of that category.
  /// [lastAttempt]: last request attempt in this app session (success or
  /// failure).
  static bool isDue({
    required QuoteCategory category,
    required DateTime now,
    required DateTime? lastSuccess,
    required DateTime? lastAttempt,
    required MarketCalendar calendar,
    bool manual = false,
    DateTime? backoffUntil,
  }) {
    if (_backingOff(now, backoffUntil)) return false;
    if (category == QuoteCategory.stocks && !isSessionOpen(now, calendar)) {
      return false;
    }
    if (_coolingDown(now, lastAttempt, manual: manual)) return false;
    return lastSuccess == null || _since(lastSuccess, now) >= interval;
  }

  /// Whether held stocks that have **no cached price** should be fetched
  /// now. Ignores the session and the 30 minute rule; only a failed attempt
  /// for them in the last [interval] (automatic refresh) or a rate-limit
  /// backoff holds it back.
  static bool isMissingStocksDue({
    required DateTime now,
    required DateTime? lastAttempt,
    bool manual = false,
    DateTime? backoffUntil,
  }) =>
      !_backingOff(now, backoffUntil) &&
      !_coolingDown(now, lastAttempt, manual: manual);

  static bool _backingOff(DateTime now, DateTime? until) =>
      until != null && now.isBefore(until);

  static bool _coolingDown(
    DateTime now,
    DateTime? lastAttempt, {
    required bool manual,
  }) => !manual && lastAttempt != null && _since(lastAttempt, now) < interval;

  /// Earliest time a category with this [lastSuccess] may update again;
  /// `null` if it has never been updated.
  static DateTime? nextUpdate(DateTime? lastSuccess) =>
      lastSuccess?.add(interval);

  /// Exponential backoff after HTTP 429: 1, 2, 4, 8, 16, 30, 30 … minutes.
  /// A server-provided `Retry-After` wins if it is longer.
  static Duration backoff(int consecutiveFailures, {Duration? retryAfter}) {
    final exponent = math.max(0, math.min(consecutiveFailures - 1, 10));
    final computed = Duration(minutes: 1 << exponent);
    final capped = computed > maxBackoff ? maxBackoff : computed;
    if (retryAfter != null && retryAfter > capped) return retryAfter;
    return capped;
  }

  static Duration _since(DateTime t, DateTime now) => now.difference(t);
}
