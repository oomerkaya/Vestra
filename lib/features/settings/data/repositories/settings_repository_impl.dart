import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/core/utils/app_logger.dart';
import 'package:capira/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:capira/features/settings/domain/entities/theme_preference.dart';
import 'package:capira/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._local);

  static const themeKey = 'theme_preference';
  static const displayCurrencyKey = 'display_currency';
  static const privacyKey = 'privacy_mode';

  final SettingsLocalDataSource _local;

  @override
  Future<Result<ThemePreference>> getThemePreference() async {
    try {
      final raw = await _local.read(themeKey);
      final match = ThemePreference.values.where((p) => p.name == raw);
      return Success(match.isEmpty ? ThemePreference.system : match.first);
    } on Object catch (error, stackTrace) {
      AppLogger.error('read theme', error: error, stackTrace: stackTrace);
      return Err(StorageFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> setThemePreference(ThemePreference preference) async {
    try {
      await _local.write(themeKey, preference.name);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      AppLogger.error('write theme', error: error, stackTrace: stackTrace);
      return Err(StorageFailure(error.toString()));
    }
  }

  @override
  Future<Result<DisplayCurrency>> getDisplayCurrency() => _read(
    displayCurrencyKey,
    (raw) =>
        DisplayCurrency.values.where((c) => c.name == raw).firstOrNull ??
        DisplayCurrency.tryLira,
  );

  @override
  Future<Result<void>> setDisplayCurrency(DisplayCurrency currency) =>
      _write(displayCurrencyKey, currency.name);

  @override
  Future<Result<bool>> getPrivacyMode() =>
      _read(privacyKey, (raw) => raw == 'true');

  @override
  Future<Result<void>> setPrivacyMode({required bool hidden}) =>
      _write(privacyKey, '$hidden');

  Future<Result<T>> _read<T>(String key, T Function(String? raw) parse) async {
    try {
      return Success(parse(await _local.read(key)));
    } on Object catch (error, stackTrace) {
      AppLogger.error('read $key', error: error, stackTrace: stackTrace);
      return Err(StorageFailure(error.toString()));
    }
  }

  Future<Result<void>> _write(String key, String value) async {
    try {
      await _local.write(key, value);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      AppLogger.error('write $key', error: error, stackTrace: stackTrace);
      return Err(StorageFailure(error.toString()));
    }
  }
}
