import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/market_calendar.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/repositories/market_repository.dart';
import 'package:vestra/features/market/domain/services/refresh_policy.dart';
import 'package:vestra/features/market/market_providers.dart';

@immutable
class PriceRefreshState {
  const PriceRefreshState({
    this.isRefreshing = false,
    this.lastReport,
    this.lastError,
    this.backoffUntil,
    this.consecutiveFailures = 0,
  });

  final bool isRefreshing;
  final RefreshReport? lastReport;

  /// Set when the whole refresh failed (e.g. database error).
  final Failure? lastError;
  final DateTime? backoffUntil;
  final int consecutiveFailures;

  PriceRefreshState copyWith({
    bool? isRefreshing,
    RefreshReport? lastReport,
    Failure? Function()? lastError,
    DateTime? Function()? backoffUntil,
    int? consecutiveFailures,
  }) => PriceRefreshState(
    isRefreshing: isRefreshing ?? this.isRefreshing,
    lastReport: lastReport ?? this.lastReport,
    lastError: lastError != null ? lastError() : this.lastError,
    backoffUntil: backoffUntil != null ? backoffUntil() : this.backoffUntil,
    consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
  );
}

/// Drives price updates while the app is in the foreground.
///
/// - Checks [RefreshPolicy] every minute and when the app is resumed.
/// - Does nothing while the app is in the background (no background
///   service, per CLAUDE.md).
/// - Manual refresh (pull-to-refresh) ignores the schedule but still
///   respects backoff.
final priceRefreshControllerProvider =
    NotifierProvider<PriceRefreshController, PriceRefreshState>(
      PriceRefreshController.new,
    );

class PriceRefreshController extends Notifier<PriceRefreshState> {
  static const Duration _tick = Duration(minutes: 1);

  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  bool _foreground = true;

  /// Clock override for tests.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  PriceRefreshState build() {
    if (ref.watch(autoRefreshEnabledProvider)) {
      _timer = Timer.periodic(_tick, (_) => unawaited(maybeAutoRefresh()));
      _lifecycle = AppLifecycleListener(
        onResume: () {
          _foreground = true;
          unawaited(maybeAutoRefresh());
        },
        onHide: () => _foreground = false,
      );
      // First check right after start-up.
      unawaited(Future<void>.microtask(maybeAutoRefresh));
    }
    ref.onDispose(() {
      _timer?.cancel();
      _lifecycle?.dispose();
    });
    return const PriceRefreshState();
  }

  /// Refreshes if the schedule allows it.
  Future<void> maybeAutoRefresh() async {
    if (!_foreground || state.isRefreshing) return;
    final MarketCalendar calendar;
    final List<Quote> quotes;
    try {
      calendar = await ref.read(marketCalendarProvider.future);
      quotes = await ref.read(quotesProvider.future);
    } on Object {
      return;
    }
    if (!ref.mounted) return;

    final should = RefreshPolicy.shouldAutoRefresh(
      now: clock(),
      lastFetchedAt: _latestFetch(quotes),
      calendar: calendar,
      backoffUntil: state.backoffUntil,
    );
    if (should) await refresh();
  }

  /// Runs a refresh now. Returns the report, or `null` if skipped/failed.
  Future<RefreshReport?> refresh({bool manual = false}) async {
    if (state.isRefreshing) return null;
    final until = state.backoffUntil;
    if (until != null && clock().isBefore(until) && !manual) return null;

    state = state.copyWith(isRefreshing: true);
    final result = await ref.read(refreshPricesProvider)();
    if (!ref.mounted) return null;

    switch (result) {
      case Success(value: final report):
        final failures = report.failures.values;
        final rateLimited = failures.whereType<RateLimitFailure>().firstOrNull;
        final allNetworkDown =
            report.updated == 0 && failures.any((f) => f is NetworkFailure);
        if (rateLimited != null || allNetworkDown) {
          final count = state.consecutiveFailures + 1;
          state = state.copyWith(
            isRefreshing: false,
            lastReport: report,
            lastError: () => null,
            consecutiveFailures: count,
            backoffUntil: () => clock().add(
              RefreshPolicy.backoff(
                count,
                retryAfter: rateLimited?.retryAfter,
              ),
            ),
          );
        } else {
          state = state.copyWith(
            isRefreshing: false,
            lastReport: report,
            lastError: () => null,
            consecutiveFailures: 0,
            backoffUntil: () => null,
          );
        }
        ref.invalidate(quotaUsageProvider);
        return report;
      case Err(:final failure):
        state = state.copyWith(isRefreshing: false, lastError: () => failure);
        return null;
    }
  }

  static DateTime? _latestFetch(List<Quote> quotes) {
    DateTime? latest;
    for (final q in quotes) {
      if (latest == null || q.fetchedAt.isAfter(latest)) latest = q.fetchedAt;
    }
    return latest;
  }
}
