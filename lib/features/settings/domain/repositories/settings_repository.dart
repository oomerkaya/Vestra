import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/features/settings/domain/entities/theme_preference.dart';

/// Non-secret app preferences. API keys live in secure storage (Phase 3).
abstract interface class SettingsRepository {
  /// Returns [ThemePreference.system] when nothing has been saved yet.
  Future<Result<ThemePreference>> getThemePreference();

  Future<Result<void>> setThemePreference(ThemePreference preference);

  /// [DisplayCurrency.tryLira] when nothing has been saved yet.
  Future<Result<DisplayCurrency>> getDisplayCurrency();

  Future<Result<void>> setDisplayCurrency(DisplayCurrency currency);

  /// Whether amounts are hidden; `false` when nothing has been saved yet.
  Future<Result<bool>> getPrivacyMode();

  Future<Result<void>> setPrivacyMode({required bool hidden});
}
