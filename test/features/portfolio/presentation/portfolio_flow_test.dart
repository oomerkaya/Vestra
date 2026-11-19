import 'package:capira/app.dart';
import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/di/database_provider.dart';
import 'package:capira/core/domain/instrument.dart';
import 'package:capira/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:capira/features/market/data/mappers/quote_mappers.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:capira/features/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

/// End-to-end UI flow on an in-memory database with a cached USD price.
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(
      () => PriceCacheLocalDataSource(db).upsertAll([
        Quote(
          instrument: (type: AssetType.currency, code: 'USD'),
          priceTry: d('42.10'),
          source: QuoteSource.burkut,
          fetchedAt: DateTime.now(),
        ).toCompanion(),
      ]),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          autoRefreshEnabledProvider.overrideWithValue(false),
          // A saved (fake) key: no "key needed" card above the list.
          apiKeyRepositoryProvider.overrideWithValue(
            FakeApiKeyRepository('bk_test_fake'),
          ),
        ],
        child: const CapiraApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text).last;
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> addUsd(WidgetTester tester, String quantity) async {
    await tapText(tester, 'Varlık ekle');
    await tapText(tester, 'Varlık seç');
    await tapText(tester, 'Amerikan Doları');
    // Price is prefilled from the cached quote.
    expect(find.text('Güncel fiyatla dolduruldu'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Miktar'),
      quantity,
    );
    await tapText(tester, 'Kaydet');
  }

  testWidgets('adding a currency shows it valued in the portfolio', (
    tester,
  ) async {
    await pumpApp(tester);

    await addUsd(tester, '100');

    expect(find.text('İşlem kaydedildi'), findsOneWidget);
    expect(find.text('Amerikan Doları'), findsOneWidget);
    expect(find.text('₺4.210,00'), findsWidgets); // value of 100 × 42,10
    expect(find.text('DAĞILIM'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('selling more than held is rejected with a message', (
    tester,
  ) async {
    await pumpApp(tester);
    await addUsd(tester, '100');

    await tapText(tester, 'Amerikan Doları');
    await tapText(tester, 'Satış ekle');
    await tester.enterText(find.widgetWithText(TextField, 'Miktar'), '150');
    await tapText(tester, 'Kaydet');

    expect(
      find.textContaining('elindeki miktardan fazla satamazsın'),
      findsOneWidget,
    );

    await unmount(tester);
  });

  testWidgets('editing and deleting the asset from its detail screen', (
    tester,
  ) async {
    await pumpApp(tester);
    await addUsd(tester, '100');

    // Open detail, then the single transaction, change quantity to 200.
    await tapText(tester, 'Amerikan Doları');
    expect(find.text('100 USD'), findsWidgets);
    await tapText(tester, 'Alım · ${_today()}');
    await tester.enterText(find.widgetWithText(TextField, 'Miktar'), '200');
    await tapText(tester, 'Kaydet');
    expect(find.text('200 USD'), findsWidgets);

    // Delete the whole asset.
    await tester.tap(find.byTooltip('Varlığı sil'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Sil');

    expect(find.text('Varlık silindi'), findsOneWidget);
    expect(find.text('Portföyün boş'), findsOneWidget);

    await unmount(tester);
  });
}

String _today() {
  final d = DateTime.now();
  return '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}
