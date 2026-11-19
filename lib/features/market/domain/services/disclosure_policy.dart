import 'package:capira/features/market/domain/entities/quota_usage.dart';
import 'package:capira/features/market/domain/services/refresh_policy.dart';

/// When KAP disclosures are fetched. Pure and fully testable.
///
/// Rules (decided with the user on 2026-11-19, docs/faz-4-ozellikler.md
/// section 11):
/// - **One request a day:** the general feed (all companies, the latest
///   500 disclosures, about 29 hours) once per Istanbul day, from 08:00,
///   while the app is open. Never a request per stock, never older pages:
///   days the app is not opened stay a gap.
/// - Everything is stored for [keepFor]; the screens only read storage.
/// - No quota threshold of its own (one request a day); only a used-up
///   quota stops it.
/// - After a failed attempt the next try waits [retryWait].
abstract final class DisclosurePolicy {
  /// Stored disclosures older than this are deleted.
  static const Duration keepFor = Duration(days: 30);

  /// A disclosure this recent marks its holding as "new".
  static const Duration newWindow = Duration(hours: 24);

  static const int earliestHour = 8;
  static const Duration retryWait = Duration(minutes: 60);

  /// Whether fetching is allowed with this quota usage.
  static bool allowed(QuotaUsage usage) => !usage.isExhausted;

  /// Once per Istanbul day, from 08:00; the very first fetch any time.
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
