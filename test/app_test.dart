import 'package:capira/app.dart';
import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/di/database_provider.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:capira/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:capira/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:capira/features/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
        child: const CapiraApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Drift closes stream queries with a zero-delay timer; unmount the app
  /// and let those timers run before the test body ends.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  Brightness currentBrightness(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).last)).brightness;

  testWidgets('starts on portfolio tab with empty state', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Portföyün boş'), findsOneWidget);

    await unmount(tester);
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

    await unmount(tester);
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

    await unmount(tester);
  });
}
