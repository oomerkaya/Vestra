import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/app.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/di/database_provider.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:vestra/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:vestra/features/settings/settings_providers.dart';

import 'helpers/fakes.dart';
import 'helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          autoRefreshEnabledProvider.overrideWithValue(false),
          apiKeyRepositoryProvider.overrideWithValue(FakeApiKeyRepository()),
        ],
        child: const VestraApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Brightness currentBrightness(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).last)).brightness;

  testWidgets('starts on portfolio tab with empty state', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Portföyün boş'), findsOneWidget);
  });

  testWidgets('switching to dark theme is applied and persisted', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karanlık'));
    await tester.pumpAndSettle();

    expect(currentBrightness(tester), Brightness.dark);
    final saved = await tester.runAsync(
      () => SettingsLocalDataSource(db).read(SettingsRepositoryImpl.themeKey),
    );
    expect(saved, 'dark');
  });

  testWidgets('saved theme is restored on start', (tester) async {
    await tester.runAsync(
      () => SettingsLocalDataSource(
        db,
      ).write(SettingsRepositoryImpl.themeKey, 'dark'),
    );

    await pumpApp(tester);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(currentBrightness(tester), Brightness.dark);
  });
}
