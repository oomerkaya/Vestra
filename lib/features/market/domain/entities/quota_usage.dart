/// Requests made to a metered provider in the current calendar month.
class QuotaUsage {
  const QuotaUsage({
    required this.period,
    required this.used,
    required this.limit,
    this.exhaustedByServer = false,
    this.resetAt,
  });

  /// Bürküt free plan: 1,000 requests per month.
  static const int burkutFreeLimit = 1000;

  /// `YYYY-MM` of the month this usage belongs to.
  final String period;
  final int used;
  final int limit;

  /// The provider itself reported the quota as used up.
  final bool exhaustedByServer;

  /// When the provider resets the monthly count; `null` until reported.
  final DateTime? resetAt;

  bool get isExhausted => exhaustedByServer || used >= limit;

  int get remaining => (limit - used).clamp(0, limit);

  static String periodOf(DateTime time) {
    final local = time.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}';
  }
}

/// The provider's own view of the monthly quota (Bürküt `/quota`).
class QuotaStatus {
  const QuotaStatus({
    required this.limit,
    required this.used,
    required this.remaining,
    this.resetAt,
  });

  final int limit;
  final int used;
  final int remaining;
  final DateTime? resetAt;
}
