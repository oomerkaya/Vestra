import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/domain/instrument.dart';
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
///   and on pull-to-refresh. Pull-to-refresh never bypasses the 30 minute
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

  /// Last attempt to fetch stocks that had no price (separate from the
  /// regular stock schedule).
  DateTime? _lastMissingAttempt;

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
      // A newly added stock gets its price right away (see
      // RefreshPolicy.isMissingStocksDue), not on the next tick.
      ref.listen(heldStockSymbolsProvider, (previous, next) {
        final before = previous?.value;
        final after = next.value;
        if (before != null &&
            after != null &&
            after.difference(before).isNotEmpty) {
          unawaited(refreshDue());
        }
      });
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
    final Set<String> held;
    try {
      calendar = await ref.read(marketCalendarProvider.future);
      quotes = await ref.read(quotesProvider.future);
      held = await ref.read(heldStockSymbolsProvider.future);
    } on Object {
      return const {};
    }
    if (!ref.mounted) return const {};

    final now = clock();
    final lastSuccess = _lastSuccessByCategory(quotes, held);
    final cachedStocks = {
      for (final q in quotes)
        if (q.instrument.type == AssetType.stock) q.instrument.code,
    };
    final due = <QuoteCategory>{
      for (final category in QuoteCategory.values)
        if (category != QuoteCategory.stocks || held.isNotEmpty)
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
    // A regular stock request covers missing symbols too.
    if (due.contains(QuoteCategory.stocks)) _lastMissingAttempt = now;

    // Stocks without any price (e.g. just added): fetch only those, even
    // outside the session. Other stocks keep their session schedule.
    var stockSymbols = held;
    final missing = {
      for (final s in held)
        if (!cachedStocks.contains(s)) s,
    };
    if (!due.contains(QuoteCategory.stocks) &&
        missing.isNotEmpty &&
        RefreshPolicy.isMissingStocksDue(
          now: now,
          lastAttempt: _lastMissingAttempt,
          manual: manual,
          backoffUntil: state.backoffUntil,
        )) {
      due.add(QuoteCategory.stocks);
      stockSymbols = missing;
      _lastMissingAttempt = now;
    }
    if (due.isEmpty) return const {};
    state = PriceRefreshState(
      refreshing: due,
      failures: state.failures,
      backoffUntil: state.backoffUntil,
      rateLimitStrikes: state.rateLimitStrikes,
    );

    final result = await ref
        .read(marketRepositoryProvider)
        .refresh(categories: due, stockSymbols: stockSymbols);
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

  /// When each category was last updated.
  ///
  /// FX and metals: newest `fetchedAt` (fetched together). Stocks: the
  /// **oldest** `fetchedAt` among held stocks, so fetching one newly added
  /// stock doesn't make the others look fresh; sold stocks are ignored.
  static Map<QuoteCategory, DateTime> _lastSuccessByCategory(
    List<Quote> quotes,
    Set<String> held,
  ) {
    final result = <QuoteCategory, DateTime>{};
    for (final q in quotes) {
      final category = QuoteCategory.of(q.instrument.type);
      final isStock = category == QuoteCategory.stocks;
      if (isStock && !held.contains(q.instrument.code)) continue;
      final current = result[category];
      final replace =
          current == null ||
          (isStock
              ? q.fetchedAt.isBefore(current)
              : q.fetchedAt.isAfter(current));
      if (replace) result[category] = q.fetchedAt;
    }
    return result;
  }
}
