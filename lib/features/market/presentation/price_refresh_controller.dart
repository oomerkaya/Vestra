import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/market_calendar.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/services/refresh_policy.dart';
import 'package:vestra/features/market/market_providers.dart';

@immutable
class PriceRefreshState {
  const PriceRefreshState({
    this.refreshing = const {},
    this.failures = const {},
    this.lastError,
    this.backoffUntil,
    this.rateLimitStrikes = 0,
  });

  /// Categories with a request in flight.
  final Set<QuoteCategory> refreshing;

  /// Latest failure per category; cleared when that category succeeds.
  final Map<QuoteCategory, Failure> failures;

  /// Set when the whole refresh failed (e.g. database error).
  final Failure? lastError;

  /// No requests at all before this time (after HTTP 429).
  final DateTime? backoffUntil;
  final int rateLimitStrikes;

  bool get isRefreshing => refreshing.isNotEmpty;
}

/// Drives price updates while the app is in the foreground, per category.
///
/// - Checks [RefreshPolicy.isDue] every minute, when the app is resumed
///   and on pull-to-refresh. Pull-to-refresh never bypasses the 60 minute
///   rule or the stock session hours; it only skips the retry wait after a
///   failed attempt.
/// - Nothing runs while the app is in the background.
final priceRefreshControllerProvider =
    NotifierProvider<PriceRefreshController, PriceRefreshState>(
      PriceRefreshController.new,
    );

class PriceRefreshController extends Notifier<PriceRefreshState> {
  static const Duration _tick = Duration(minutes: 1);

  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  bool _foreground = true;
  final Map<QuoteCategory, DateTime> _lastAttempt = {};
  DateTime? _quotaSyncedAt;

  /// The free `/quota` check runs at most this often, unless forced.
  static const Duration _quotaSyncInterval = Duration(minutes: 10);

  /// Clock override for tests.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  PriceRefreshState build() {
    if (ref.watch(autoRefreshEnabledProvider)) {
      _timer = Timer.periodic(_tick, (_) => unawaited(refreshDue()));
      _lifecycle = AppLifecycleListener(
        onResume: () {
          _foreground = true;
          unawaited(refreshDue());
        },
        onHide: () => _foreground = false,
      );
      unawaited(Future<void>.microtask(refreshDue));
    }
    ref.onDispose(() {
      _timer?.cancel();
      _lifecycle?.dispose();
    });
    return const PriceRefreshState();
  }

  /// Fetches every category that is due. With [manual] (pull-to-refresh)
  /// a failed category may be retried immediately; everything else follows
  /// the same rules as the automatic refresh. Returns the categories that
  /// were requested (empty if nothing was due).
  Future<Set<QuoteCategory>> refreshDue({bool manual = false}) async {
    if ((!manual && !_foreground) || state.isRefreshing) return const {};

    final MarketCalendar calendar;
    final List<Quote> quotes;
    try {
      calendar = await ref.read(marketCalendarProvider.future);
      quotes = await ref.read(quotesProvider.future);
    } on Object {
      return const {};
    }
    if (!ref.mounted) return const {};

    final repository = ref.read(marketRepositoryProvider);
    // Free: aligns the counter with the server before deciding, so an
    // exhausted quota sends nothing.
    await syncQuota();
    if (!ref.mounted) return const {};
    final stocksSnapshot = await repository.stocksSnapshotAt();
    if (!ref.mounted) return const {};

    final now = clock();
    final lastSuccess = _lastSuccessByCategory(quotes)
      // Stocks count as fetched only after a whole-market snapshot.
      ..[QuoteCategory.stocks] = stocksSnapshot;
    final due = <QuoteCategory>{
      for (final category in QuoteCategory.values)
        if (RefreshPolicy.isDue(
          category: category,
          now: now,
          lastSuccess: lastSuccess[category],
          lastAttempt: _lastAttempt[category],
          calendar: calendar,
          manual: manual,
          backoffUntil: state.backoffUntil,
        ))
          category,
    };
    for (final category in due) {
      _lastAttempt[category] = now;
    }
    if (due.isEmpty) return const {};
    state = PriceRefreshState(
      refreshing: due,
      failures: state.failures,
      backoffUntil: state.backoffUntil,
      rateLimitStrikes: state.rateLimitStrikes,
    );

    final result = await repository.refresh(categories: due);
    if (!ref.mounted) return due;

    switch (result) {
      case Success(value: final report):
        final failures = {...state.failures}
          ..removeWhere((c, _) => due.contains(c))
          ..addAll(report.failures);
        final rateLimited = report.failures.values
            .whereType<RateLimitFailure>()
            .firstOrNull;
        final strikes = rateLimited == null ? 0 : state.rateLimitStrikes + 1;
        state = PriceRefreshState(
          failures: failures,
          rateLimitStrikes: strikes,
          backoffUntil: rateLimited == null
              ? null
              : now.add(
                  RefreshPolicy.backoff(
                    strikes,
                    retryAfter: rateLimited.retryAfter,
                  ),
                ),
        );
        ref.invalidate(quotaUsageProvider);
      case Err(:final failure):
        state = PriceRefreshState(
          failures: state.failures,
          lastError: failure,
          backoffUntil: state.backoffUntil,
          rateLimitStrikes: state.rateLimitStrikes,
        );
    }
    return due;
  }

  /// Replaces the local quota count with the server's own (`/quota`,
  /// costs no request). At most every 10 minutes unless [force]d, e.g.
  /// when the settings screen opens. Failures are ignored: the local count
  /// stays in use.
  Future<void> syncQuota({bool force = false}) async {
    final now = clock();
    final last = _quotaSyncedAt;
    if (!force && last != null && now.difference(last) < _quotaSyncInterval) {
      return;
    }
    _quotaSyncedAt = now;
    final result = await ref.read(marketRepositoryProvider).syncQuota();
    if (ref.mounted && result is Success) ref.invalidate(quotaUsageProvider);
  }

  /// Newest `fetchedAt` per category (each category is fetched as a
  /// whole). Stocks are overridden by the whole-market snapshot time.
  static Map<QuoteCategory, DateTime?> _lastSuccessByCategory(
    List<Quote> quotes,
  ) {
    final result = <QuoteCategory, DateTime?>{};
    for (final q in quotes) {
      final category = QuoteCategory.of(q.instrument.type);
      final current = result[category];
      if (current == null || q.fetchedAt.isAfter(current)) {
        result[category] = q.fetchedAt;
      }
    }
    return result;
  }
}
