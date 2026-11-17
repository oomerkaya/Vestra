import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/settings/domain/entities/theme_preference.dart';

/// Non-secret app preferences. API keys live in secure storage (Phase 3).
abstract interface class SettingsRepository {
  /// Returns [ThemePreference.system] when nothing has been saved yet.
  Future<Result<ThemePreference>> getThemePreference();

  Future<Result<void>> setThemePreference(ThemePreference preference);
}
