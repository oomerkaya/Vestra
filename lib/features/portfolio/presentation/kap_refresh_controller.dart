import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/services/disclosure_policy.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/portfolio/domain/services/portfolio_valuator.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';

/// What the KAP refresher is doing right now.
@immutable
class KapRefreshState {
  const KapRefreshState({this.loading = const {}, this.feedLoading = false});

  /// Single stocks with a request in flight.
  final Set<String> loading;
  final bool feedLoading;

  bool get isBusy => feedLoading || loading.isNotEmpty;
}

/// Keeps KAP disclosures of held stocks up to date ([DisclosurePolicy]).
///
/// - Automatically (20 s after start, every 15 minutes and when the app is
///   resumed), while less than half of the monthly quota is used:
///   1. the 5 most valuable held stocks that were never fetched, one
///      request each, for their recent history;
///   2. the general feed once a day, one request for all held stocks.
/// - [KapRefreshController.ensureFresh]: a held stock's detail screen,
///   only once automatic fetching has stopped for the quota.
/// - Nothing runs while the app is in the background.
final kapRefreshControllerProvider =
    NotifierProvider<KapRefreshController, KapRefreshState>(
      KapRefreshController.new,
    );

class KapRefreshController extends Notifier<KapRefreshState> {
  static const Duration _tick = Duration(minutes: 15);

  /// The price refresh runs first at start-up, so the 10 requests/minute
  /// limit is never reached (4 price + at most 6 KAP requests).
  static const Duration _startDelay = Duration(seconds: 20);

  Timer? _timer;
  Timer? _start;
  AppLifecycleListener? _lifecycle;
  bool _foreground = true;
  bool _autoRunning = false;
  DateTime? _feedAttempt;
  final Map<String, DateTime> _lastAttempt = {};

  /// Clock override for tests.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  KapRefreshState build() {
    // Keep the inputs alive: unlistened providers are paused and reading
    // their `.future` would never complete.
    ref
      ..listen(holdingsProvider, (_, _) {})
      ..listen(quotesProvider, (_, _) {})
      ..listen(quotaUsageProvider, (_, _) {});
    if (ref.watch(autoRefreshEnabledProvider)) {
      _start = Timer(_startDelay, () => unawaited(refreshAuto()));
      _timer = Timer.periodic(_tick, (_) {
        if (_foreground) unawaited(refreshAuto());
      });
      _lifecycle = AppLifecycleListener(
        onResume: () {
          _foreground = true;
          unawaited(refreshAuto());
        },
        onHide: () => _foreground = false,
      );
    }
    ref.onDispose(() {
      _start?.cancel();
      _timer?.cancel();
      _lifecycle?.dispose();
    });
    return const KapRefreshState();
  }

  /// Runs the automatic steps that are due. Returns the number of requests
  /// started (each single stock and each feed run counts once).
  Future<int> refreshAuto() async {
    if (_autoRunning) return 0;
    _autoRunning = true;
    try {
      final holdings = await ref.read(holdingsProvider.future);
      final quotes = await ref.read(quotesProvider.future);
      final usage = await ref.read(quotaUsageProvider.future);
      if (!ref.mounted) return 0;

      final stocks = [
        for (final v in PortfolioValuator.value(holdings, quotes).holdings)
          if (v.holding.asset.type == AssetType.stock)
            (symbol: v.holding.asset.code, value: v.marketValue),
      ];
      final held = {for (final s in stocks) s.symbol};
      final repository = ref.read(disclosureRepositoryProvider);
      await repository.keepOnly(held);
      if (held.isEmpty || usage == null) return 0;
      if (!DisclosurePolicy.autoAllowed(usage)) return 0;

      // 1. History for top stocks never fetched on their own.
      final firstTime = <String>[
        for (final s in DisclosurePolicy.autoSymbols(stocks))
          if (await repository.lastFetchedAt(s) == null) s,
      ];
      final (started, stop) = await _fetchSymbols(firstTime);
      if (stop || !ref.mounted) return started;

      // 2. The daily feed for all held stocks.
      final now = clock();
      final feedDue = DisclosurePolicy.isDue(
        now: now,
        lastFetched: await repository.lastFeedAt(),
        lastAttempt: _feedAttempt,
      );
      if (!feedDue || !ref.mounted) return started;
      _feedAttempt = now;
      state = KapRefreshState(loading: state.loading, feedLoading: true);
      await repository.refreshFeed(held);
      if (ref.mounted) {
        state = KapRefreshState(loading: state.loading);
        ref.invalidate(quotaUsageProvider);
      }
      return started + 1;
    } on Object {
      return 0;
    } finally {
      _autoRunning = false;
    }
  }

  /// Detail screen of a held stock. Fetches it only when automatic
  /// fetching has stopped (half the quota used) and nothing updated it
  /// today. Returns whether a request was sent.
  Future<bool> ensureFresh(String symbol) async {
    final code = symbol.toUpperCase();
    try {
      final usage = await ref.read(quotaUsageProvider.future);
      if (!ref.mounted || usage == null) return false;
      if (DisclosurePolicy.autoAllowed(usage)) return false;
      final repository = ref.read(disclosureRepositoryProvider);
      final fresh = DisclosurePolicy.freshToday(
        now: clock(),
        feedAt: await repository.lastFeedAt(),
        symbolAt: await repository.lastFetchedAt(code),
      );
      if (fresh) return false;
      final (started, _) = await _fetchSymbols([code]);
      return started > 0;
    } on Object {
      return false;
    }
  }

  /// Marks every disclosure as seen (the list was opened).
  Future<void> markSeen() =>
      ref.read(disclosureRepositoryProvider).markSeen(clock());

  /// One request per due symbol. Returns how many were started and whether
  /// to stop (no key, no quota or rate limited).
  Future<(int, bool)> _fetchSymbols(List<String> symbols) async {
    final repository = ref.read(disclosureRepositoryProvider);
    var started = 0;
    for (final symbol in symbols) {
      if (!ref.mounted) return (started, true);
      if (state.loading.contains(symbol)) continue;
      final now = clock();
      final due = DisclosurePolicy.isDue(
        now: now,
        lastFetched: await repository.lastFetchedAt(symbol),
        lastAttempt: _lastAttempt[symbol],
      );
      if (!due || !ref.mounted) continue;

      _lastAttempt[symbol] = now;
      started++;
      state = KapRefreshState(
        loading: {...state.loading, symbol},
        feedLoading: state.feedLoading,
      );
      final result = await repository.refresh(symbol);
      if (!ref.mounted) return (started, true);
      state = KapRefreshState(
        loading: {...state.loading}..remove(symbol),
        feedLoading: state.feedLoading,
      );
      if (result case Err(
        failure: AuthFailure() || QuotaExceededFailure() || RateLimitFailure(),
      )) {
        ref.invalidate(quotaUsageProvider);
        return (started, true);
      }
    }
    if (started > 0 && ref.mounted) ref.invalidate(quotaUsageProvider);
    return (started, false);
  }
}
