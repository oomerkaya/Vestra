import 'dart:async';

import 'package:capira/features/market/domain/services/disclosure_policy.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads the general KAP feed once a day ([DisclosurePolicy]) while the
/// app is open: 20 s after start (the price refresh goes first), every
/// 15 minutes and when the app is resumed. One request a day at most;
/// nothing in the background, so days the app is not opened stay a gap.
/// State: whether the feed request is in flight.
final kapRefreshControllerProvider =
    NotifierProvider<KapRefreshController, bool>(KapRefreshController.new);

class KapRefreshController extends Notifier<bool> {
  static const Duration _tick = Duration(minutes: 15);
  static const Duration _startDelay = Duration(seconds: 20);

  Timer? _timer;
  Timer? _start;
  AppLifecycleListener? _lifecycle;
  bool _foreground = true;
  DateTime? _lastAttempt;

  /// Clock override for tests.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  bool build() {
    // Keep the quota alive: unlistened providers are paused and reading
    // their `.future` would never complete.
    ref.listen(quotaUsageProvider, (_, _) {});
    if (ref.watch(autoRefreshEnabledProvider)) {
      _start = Timer(_startDelay, () => unawaited(refreshDue()));
      _timer = Timer.periodic(_tick, (_) {
        if (_foreground) unawaited(refreshDue());
      });
      _lifecycle = AppLifecycleListener(
        onResume: () {
          _foreground = true;
          unawaited(refreshDue());
        },
        onHide: () => _foreground = false,
      );
    }
    ref.onDispose(() {
      _start?.cancel();
      _timer?.cancel();
      _lifecycle?.dispose();
    });
    return false;
  }

  /// Reads the feed if it is due. Returns whether a request was sent.
  Future<bool> refreshDue() async {
    if (state) return false;
    try {
      final repository = ref.read(disclosureRepositoryProvider);
      await repository.prune();
      final usage = await ref.read(quotaUsageProvider.future);
      if (!ref.mounted || usage == null) return false;
      if (!DisclosurePolicy.allowed(usage)) return false;

      final now = clock();
      final due = DisclosurePolicy.isDue(
        now: now,
        lastFetched: await repository.lastFeedAt(),
        lastAttempt: _lastAttempt,
      );
      if (!due || !ref.mounted) return false;

      _lastAttempt = now;
      state = true;
      await repository.refreshFeed();
      if (ref.mounted) {
        state = false;
        ref.invalidate(quotaUsageProvider);
      }
      return true;
    } on Object {
      if (ref.mounted) state = false;
      return false;
    }
  }

  /// Marks every disclosure as seen (the list was opened).
  Future<void> markSeen() =>
      ref.read(disclosureRepositoryProvider).markSeen(clock());
}
