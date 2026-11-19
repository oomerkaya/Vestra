import 'package:decimal/decimal.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/services/refresh_policy.dart';

/// When KAP disclosures may be fetched. Pure and fully testable.
///
/// Rules (decided with the user on 2026-11-19, docs/faz-4-ozellikler.md
/// section 10):
/// - Only held stocks are ever shown.
/// - **Daily feed:** once per Istanbul day, from 08:00, one request for the
///   general feed (all companies, the last ~29 hours) covers every held
///   stock. If the app was not opened for longer than one page reaches
///   back, up to [maxFeedPages] pages are read.
/// - **First time:** the [autoLimit] most valuable held stocks that were
///   never fetched get one request each, for their recent history (the
///   feed only reaches back about a day).
/// - **Quota:** once half of the monthly quota is used, nothing is
///   fetched automatically; a held stock's detail screen then fetches that
///   stock on demand, at most once a day.
/// - After a failed attempt the same request waits [retryWait].
abstract final class DisclosurePolicy {
  static const int autoLimit = 5;

  /// Disclosures requested per stock on its own.
  static const int perStock = 5;

  /// At most this many feed pages (requests) per day.
  static const int maxFeedPages = 3;

  /// Stored disclosures older than this are deleted.
  static const Duration keepFor = Duration(days: 30);

  /// A disclosure this recent marks its holding as "new".
  static const Duration newWindow = Duration(hours: 24);

  /// Automatic fetching stops once this share of the quota is used.
  static const double autoQuotaShare = 0.5;
  static const int earliestHour = 8;
  static const Duration retryWait = Duration(minutes: 60);

  /// Up to [autoLimit] symbols, highest value first; stocks without a
  /// price come last in their given order.
  static List<String> autoSymbols(
    List<({String symbol, Decimal? value})> stocks,
  ) {
    final indexed = stocks.indexed.toList()
      ..sort((a, b) {
        final va = a.$2.value;
        final vb = b.$2.value;
        if (va == null && vb == null) return a.$1.compareTo(b.$1);
        if (va == null) return 1;
        if (vb == null) return -1;
        final byValue = vb.compareTo(va);
        return byValue != 0 ? byValue : a.$1.compareTo(b.$1);
      });
    return {for (final (_, s) in indexed) s.symbol}.take(autoLimit).toList();
  }

  /// Whether automatic fetching is allowed with this quota usage.
  static bool autoAllowed(QuotaUsage usage) =>
      !usage.isExhausted && usage.used < usage.limit * autoQuotaShare;

  /// Daily rule, for the feed and for single stocks.
  static bool isDue({
    required DateTime now,
    required DateTime? lastFetched,
    DateTime? lastAttempt,
  }) {
    if (lastAttempt != null && now.difference(lastAttempt) < retryWait) {
      return false;
    }
    if (lastFetched == null) return true;
    return !_sameIstanbulDay(now, lastFetched) &&
        RefreshPolicy.toIstanbul(now).hour >= earliestHour;
  }

  /// Whether a stock's disclosures were updated today, by the feed or on
  /// their own.
  static bool freshToday({
    required DateTime now,
    DateTime? feedAt,
    DateTime? symbolAt,
  }) =>
      (feedAt != null && _sameIstanbulDay(now, feedAt)) ||
      (symbolAt != null && _sameIstanbulDay(now, symbolAt));

  /// After reading [pagesRead] feed pages, whether an older one is needed
  /// to close the gap since the previous feed fetch [lastFeedAt]. The very
  /// first fetch reads one page only.
  static bool needsOlderPage({
    required int pagesRead,
    required DateTime? oldestOnPage,
    required bool isLast,
    required DateTime? lastFeedAt,
  }) =>
      lastFeedAt != null &&
      !isLast &&
      oldestOnPage != null &&
      oldestOnPage.isAfter(lastFeedAt) &&
      pagesRead < maxFeedPages;

  static bool _sameIstanbulDay(DateTime a, DateTime b) {
    final x = RefreshPolicy.toIstanbul(a);
    final y = RefreshPolicy.toIstanbul(b);
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }
}
