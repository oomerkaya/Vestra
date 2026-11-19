import 'dart:async';

import 'package:capira/core/error/result.dart';
import 'package:capira/features/settings/domain/entities/theme_preference.dart';
import 'package:capira/features/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current theme mode, persisted through [settingsRepositoryProvider].
///
/// Starts as [ThemeMode.system] and switches to the saved value as soon as it
/// is loaded (a few ms after start-up).
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  bool _userChanged = false;

  @override
  ThemeMode build() {
    _userChanged = false;
    unawaited(_load());
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .getThemePreference();
    // Don't overwrite a choice the user made while loading.
    if (!ref.mounted || _userChanged) return;
    if (result case Success(:final value)) state = _toMode(value);
  }

  Future<void> setMode(ThemeMode mode) async {
    _userChanged = true;
    state = mode;
    await ref
        .read(settingsRepositoryProvider)
        .setThemePreference(_toPref(mode));
  }

  static ThemeMode _toMode(ThemePreference p) => switch (p) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  static ThemePreference _toPref(ThemeMode m) => switch (m) {
    ThemeMode.system => ThemePreference.system,
    ThemeMode.light => ThemePreference.light,
    ThemeMode.dark => ThemePreference.dark,
  };
}
