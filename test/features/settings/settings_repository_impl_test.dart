import 'package:capira/core/database/app_database.dart';
import 'package:capira/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:capira/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:capira/features/settings/domain/entities/theme_preference.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repo;

  setUp(() {
    db = createTestDatabase();
    repo = SettingsRepositoryImpl(SettingsLocalDataSource(db));
  });

  tearDown(() => db.close());

  test('defaults to system when nothing is saved', () async {
    expect(
      (await repo.getThemePreference()).valueOrNull,
      ThemePreference.system,
    );
  });

  test('persists and overwrites the theme preference', () async {
    await repo.setThemePreference(ThemePreference.dark);
    expect((await repo.getThemePreference()).valueOrNull, ThemePreference.dark);

    await repo.setThemePreference(ThemePreference.light);
    expect(
      (await repo.getThemePreference()).valueOrNull,
      ThemePreference.light,
    );
  });

  test('unknown stored value falls back to system', () async {
    await SettingsLocalDataSource(
      db,
    ).write(SettingsRepositoryImpl.themeKey, 'neon');
    expect(
      (await repo.getThemePreference()).valueOrNull,
      ThemePreference.system,
    );
  });
}
