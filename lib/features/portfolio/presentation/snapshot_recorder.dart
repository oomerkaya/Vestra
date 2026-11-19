import 'dart:async';

import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Writes today's portfolio value whenever the valuation changes (prices
/// refreshed, transaction added), debounced. No request is involved; the
/// value history and the weekly/monthly summary are built from these rows.
final snapshotRecorderProvider = NotifierProvider<SnapshotRecorder, void>(
  SnapshotRecorder.new,
);

class SnapshotRecorder extends Notifier<void> {
  static const Duration _debounce = Duration(seconds: 5);

  Timer? _timer;

  /// Clock override for tests.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  void build() {
    ref.onDispose(() => _timer?.cancel());
    // Off in widget tests (no timers, no writes).
    if (!ref.watch(autoRefreshEnabledProvider)) return;
    ref
      ..listen(quotesProvider, (_, _) {})
      ..listen(portfolioSummaryProvider, (_, next) {
        if (next.value case final summary?) _schedule(summary);
      }, fireImmediately: true);
  }

  void _schedule(PortfolioSummary summary) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => unawaited(recordNow(summary)));
  }

  /// Stores [summary] as today's value right away.
  Future<void> recordNow(PortfolioSummary summary) async {
    final quotes = ref.read(quotesProvider).value ?? const <Quote>[];
    await ref
        .read(recordSnapshotProvider)
        .call(summary: summary, quotes: quotes, now: clock());
  }
}
