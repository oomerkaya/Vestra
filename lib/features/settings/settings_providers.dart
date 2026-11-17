import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vestra/core/di/database_provider.dart';
import 'package:vestra/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:vestra/features/settings/data/repositories/api_key_repository_impl.dart';
import 'package:vestra/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:vestra/features/settings/domain/repositories/api_key_repository.dart';
import 'package:vestra/features/settings/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(
    SettingsLocalDataSource(ref.watch(appDatabaseProvider)),
  ),
);

final apiKeyRepositoryProvider = Provider<ApiKeyRepository>(
  (ref) => const ApiKeyRepositoryImpl(FlutterSecureStorage()),
);
