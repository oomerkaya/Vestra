import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/di/database_provider.dart';
import 'package:vestra/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:vestra/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:vestra/features/settings/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(
    SettingsLocalDataSource(ref.watch(appDatabaseProvider)),
  ),
);
