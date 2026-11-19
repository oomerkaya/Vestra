import 'dart:async';

import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/features/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Currency of the portfolio totals (₺ / $ / €), persisted.
final displayCurrencyProvider =
    NotifierProvider<DisplayCurrencyNotifier, DisplayCurrency>(
      DisplayCurrencyNotifier.new,
    );

class DisplayCurrencyNotifier extends Notifier<DisplayCurrency> {
  bool _userChanged = false;

  @override
  DisplayCurrency build() {
    _userChanged = false;
    unawaited(_load());
    return DisplayCurrency.tryLira;
  }

  Future<void> _load() async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .getDisplayCurrency();
    if (!ref.mounted || _userChanged) return;
    if (result case Success(:final value)) state = value;
  }

  Future<void> select(DisplayCurrency currency) async {
    _userChanged = true;
    state = currency;
    await ref.read(settingsRepositoryProvider).setDisplayCurrency(currency);
  }
}

/// Privacy mode: personal amounts and quantities are masked, persisted.
final privacyModeProvider = NotifierProvider<PrivacyModeNotifier, bool>(
  PrivacyModeNotifier.new,
);

class PrivacyModeNotifier extends Notifier<bool> {
  bool _userChanged = false;

  @override
  bool build() {
    _userChanged = false;
    unawaited(_load());
    return false;
  }

  Future<void> _load() async {
    final result = await ref.read(settingsRepositoryProvider).getPrivacyMode();
    if (!ref.mounted || _userChanged) return;
    if (result case Success(:final value)) state = value;
  }

  Future<void> toggle() async {
    _userChanged = true;
    state = !state;
    await ref.read(settingsRepositoryProvider).setPrivacyMode(hidden: state);
  }
}
