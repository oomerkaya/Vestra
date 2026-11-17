import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/utils/app_logger.dart';
import 'package:vestra/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:vestra/features/settings/domain/entities/theme_preference.dart';
import 'package:vestra/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._local);

  static const themeKey = 'theme_preference';

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
}
