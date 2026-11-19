import 'dart:convert';

import 'package:capira/core/database/app_database.dart';
import 'package:capira/features/market/domain/entities/quota_usage.dart';

/// Counts Bürküt requests per calendar month in `app_settings`.
///
/// The count is the app's own estimate, corrected by the server's
/// `X-Quota-Remaining` header whenever it is present and replaced by the
/// free `/quota` answer; the server's "quota exceeded" answer always wins.
class QuotaLocalDataSource {
  QuotaLocalDataSource(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const String key = 'burkut_quota';

  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<QuotaUsage> current() async {
    final period = QuotaUsage.periodOf(_clock());
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    final stored = _decode(row?.value);
    if (stored == null || stored.period != period) {
      return QuotaUsage(
        period: period,
        used: 0,
        limit: QuotaUsage.burkutFreeLimit,
      );
    }
    return stored;
  }

  Future<QuotaUsage> recordRequest() => _update(
    (u) => QuotaUsage(
      period: u.period,
      used: u.used + 1,
      limit: u.limit,
      exhaustedByServer: u.exhaustedByServer,
      resetAt: u.resetAt,
    ),
  );

  /// Replaces the counter with the server's own numbers (`/quota`).
  Future<QuotaUsage> syncStatus(QuotaStatus status) => _update(
    (u) {
      final limit = status.limit > 0 ? status.limit : u.limit;
      return QuotaUsage(
        period: u.period,
        used: status.used.clamp(0, limit),
        limit: limit,
        exhaustedByServer: status.remaining <= 0,
        resetAt: status.resetAt ?? u.resetAt,
      );
    },
  );

  /// Aligns the counter with the server's `X-Quota-Remaining` and
  /// `X-Quota-Limit` headers, which are authoritative (the server knows the
  /// user's plan and its own reset date).
  Future<QuotaUsage> syncRemaining(int remaining, {int? limit}) => _update(
    (u) {
      final effectiveLimit = limit != null && limit > 0 ? limit : u.limit;
      return QuotaUsage(
        period: u.period,
        used: (effectiveLimit - remaining).clamp(0, effectiveLimit),
        limit: effectiveLimit,
        exhaustedByServer: remaining <= 0,
        resetAt: u.resetAt,
      );
    },
  );

  Future<QuotaUsage> markExhausted() => _update(
    (u) => QuotaUsage(
      period: u.period,
      used: u.used,
      limit: u.limit,
      exhaustedByServer: true,
      resetAt: u.resetAt,
    ),
  );

  Future<QuotaUsage> _update(QuotaUsage Function(QuotaUsage) change) =>
      _db.transaction(() async {
        final next = change(await current());
        await _db
            .into(_db.appSettings)
            .insertOnConflictUpdate(
              AppSettingsCompanion.insert(key: key, value: _encode(next)),
            );
        return next;
      });

  static String _encode(QuotaUsage u) => jsonEncode({
    'period': u.period,
    'used': u.used,
    'limit': u.limit,
    'exhausted': u.exhaustedByServer,
    'resetAt': u.resetAt?.toUtc().toIso8601String(),
  });

  static QuotaUsage? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return QuotaUsage(
        period: json['period'] as String,
        used: json['used'] as int,
        limit: json['limit'] as int? ?? QuotaUsage.burkutFreeLimit,
        exhaustedByServer: json['exhausted'] as bool? ?? false,
        resetAt: DateTime.tryParse(json['resetAt'] as String? ?? ''),
      );
    } on Object {
      return null;
    }
  }
}
