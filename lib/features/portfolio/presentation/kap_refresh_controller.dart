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

/// Keeps KAP disclosures of held stocks up to date, following
/// [DisclosurePolicy]. State: symbols with a request in flight.
///
/// - Automatically (shortly after start, every 15 minutes and when the app
///   is resumed): the [DisclosurePolicy.autoLimit] most valuable held
///   stocks, each once per day, and only while enough quota is left.
/// - [KapRefreshController.ensureFresh]: one stock, when its detail screen
///   opens (same daily rule, no quota threshold).
/// - Nothing runs while the app is in the background.
final kapRefreshControllerProvider =
    NotifierProvider<KapRefreshController, Set<String>>(
      KapRefreshController.new,
    );

class KapRefreshController extends Notifier<Set<String>> {
  static const Duration _tick = Duration(minutes: 15);

  /// The price refresh runs first at start-up; with up to 4 price requests
  /// plus 5 KAP requests the 10 requests/minute limit is never reached.
  static const Duration _startDelay = Duration(seconds: 20);

  Timer? _timer;
  Timer? _start;
  AppLifecycleListener? _lifecycle;
  bool _foreground = true;
  bool _autoRunning = false;
  final Map<String, DateTime> _lastAttempt = {};

  /// Clock override for tests.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  Set<String> build() {
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
    return const {};
  }

  /// Fetches the due stocks among the most valuable held ones. Returns the
  /// symbols that were requested.
  Future<List<String>> refreshAuto() async {
    if (_autoRunning) return const [];
    _autoRunning = true;
    try {
      final holdings = await ref.read(holdingsProvider.future);
      final quotes = await ref.read(quotesProvider.future);
      final usage = await ref.read(quotaUsageProvider.future);
      if (!ref.mounted) return const [];

      final stocks = [
        for (final v in PortfolioValuator.value(holdings, quotes).holdings)
          if (v.holding.asset.type == AssetType.stock)
            (symbol: v.holding.asset.code, value: v.marketValue),
      ];
      final repository = ref.read(disclosureRepositoryProvider);
      await repository.keepOnly({for (final s in stocks) s.symbol});

      if (usage == null || !DisclosurePolicy.autoAllowed(usage)) {
        return const [];
      }
      return await _fetchDue(DisclosurePolicy.autoSymbols(stocks));
    } on Object {
      return const [];
    } finally {
      _autoRunning = false;
    }
  }

  /// Fetches [symbol] if it is due (detail screen). Returns whether a
  /// request was sent.
  Future<bool> ensureFresh(String symbol) async =>
      (await _fetchDue([symbol.toUpperCase()])).isNotEmpty;

  Future<List<String>> _fetchDue(List<String> symbols) async {
    final repository = ref.read(disclosureRepositoryProvider);
    final requested = <String>[];
    for (final symbol in symbols) {
      if (!ref.mounted || state.contains(symbol)) continue;
      final now = clock();
      final due = DisclosurePolicy.isDue(
        now: now,
        lastFetched: await repository.lastFetchedAt(symbol),
        lastAttempt: _lastAttempt[symbol],
      );
      if (!due || !ref.mounted) continue;

      _lastAttempt[symbol] = now;
      requested.add(symbol);
      state = {...state, symbol};
      final result = await repository.refresh(symbol);
      if (!ref.mounted) break;
      state = {...state}..remove(symbol);
      // No point in further requests without a key, quota or while rate
      // limited; the next run tries again.
      if (result case Err(
        failure: AuthFailure() || QuotaExceededFailure() || RateLimitFailure(),
      )) {
        break;
      }
    }
    if (requested.isNotEmpty && ref.mounted) ref.invalidate(quotaUsageProvider);
    return requested;
  }
}
