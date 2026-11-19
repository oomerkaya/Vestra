import 'package:decimal/decimal.dart';
import 'package:vestra/features/market/domain/entities/quota_usage.dart';
import 'package:vestra/features/market/domain/services/refresh_policy.dart';

/// When KAP disclosures may be fetched. Pure and fully testable.
///
/// Rules (docs/oneri-kap-bildirimleri.md, option D with a cap of 5):
/// - Automatically only for the [autoLimit] held stocks with the highest
///   value; other held stocks are fetched when their detail screen opens.
/// - Each stock at most once per Istanbul calendar day, from 08:00 on
///   (companies mostly publish before and during the session). A stock
///   that was never fetched may be fetched any time.
/// - With less than [lowQuotaShare] of the monthly quota left, nothing is
///   fetched automatically; prices always come first.
/// - After a failed attempt, the same stock waits [retryWait].
abstract final class DisclosurePolicy {
  static const int autoLimit = 5;

  /// Disclosures requested and kept per stock.
  static const int perStock = 5;

  /// The portfolio screen shows disclosures of this many recent days.
  static const Duration recentWindow = Duration(days: 7);
  static const double lowQuotaShare = 0.2;
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
      !usage.isExhausted && usage.remaining >= usage.limit * lowQuotaShare;

  static bool isDue({
    required DateTime now,
    required DateTime? lastFetched,
    DateTime? lastAttempt,
  }) {
    if (lastAttempt != null && now.difference(lastAttempt) < retryWait) {
      return false;
    }
    if (lastFetched == null) return true;
    final local = RefreshPolicy.toIstanbul(now);
    final last = RefreshPolicy.toIstanbul(lastFetched);
    final sameDay =
        local.year == last.year &&
        local.month == last.month &&
        local.day == last.day;
    return !sameDay && local.hour >= earliestHour;
  }
}
