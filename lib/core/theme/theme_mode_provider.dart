import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current theme mode. In-memory for now; persisted to the local DB in
/// Phase 2 once the settings table exists.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  // A setter would hide intent at call sites.
  // ignore: use_setters_to_change_properties
  void setMode(ThemeMode mode) => state = mode;
}
