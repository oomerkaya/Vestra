import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/app.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/di/database_provider.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/features/market/data/datasources/kap_disclosure_local_data_source.dart';
import 'package:vestra/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:vestra/features/market/data/mappers/kap_disclosure_mapper.dart';
import 'package:vestra/features/market/data/mappers/quote_mappers.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/settings/presentation/settings_screen.dart';
import 'package:vestra/features/settings/settings_providers.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

/// Portfolio screen with a held stock, its cached price and disclosures.
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<void> seed(WidgetTester tester, {required DateTime now}) =>
      tester.runAsync(() async {
        final id = await db
            .into(db.assets)
            .insert(
              AssetsCompanion.insert(
                type: 'stock',
                code: 'THYAO',
                name: 'THYAO',
              ),
            );
        await db
            .into(db.assetTransactions)
            .insert(
              AssetTransactionsCompanion.insert(
                assetId: id,
                kind: 'buy',
                quantity: d('100'),
                unitPriceTry: Value(d('300')),
                date: DateTime(2026, 10),
              ),
            );
        await PriceCacheLocalDataSource(db).upsertAll([
          Quote(
            instrument: (type: AssetType.stock, code: 'THYAO'),
            priceTry: d('323.75'),
            source: QuoteSource.burkut,
            fetchedAt: now,
            name: 'Türk Hava Yolları',
            changePercent: d('0.47'),
          ).toCompanion(),
        ]);
        await KapDisclosureLocalDataSource(db).storeFeed(
          [
            KapDisclosure(
              id: '1:THYAO',
              symbol: 'THYAO',
              title: 'Özel Durum Açıklaması (Genel)',
              summary: 'Ekim 2026 Trafik Sonuçları',
              publishedAt: now.subtract(const Duration(hours: 3)),
              url: 'https://www.kap.org.tr/tr/Bildirim/1695191',
            ).toCompanion(),
          ],
          at: now,
        );
      });

  Future<void> pumpApp(WidgetTester tester, {String? key = 'bk_fake'}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          autoRefreshEnabledProvider.overrideWithValue(false),
          apiKeyRepositoryProvider.overrideWithValue(FakeApiKeyRepository(key)),
        ],
        child: const VestraApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('company name, KAP pill and badge; the list clears the badge', (
    tester,
  ) async {
    await seed(tester, now: DateTime.now());
    await pumpApp(tester);

    expect(find.text('Türk Hava Yolları'), findsOneWidget);
    expect(find.text('KAP'), findsOneWidget, reason: 'new disclosure pill');
    expect(find.text('1'), findsOneWidget, reason: 'badge count');

    await tester.tap(find.byTooltip('KAP bildirimleri'));
    await tester.pumpAndSettle();
    expect(find.text('Ekim 2026 Trafik Sonuçları'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsNothing, reason: 'seen');

    await unmount(tester);
  });

  testWidgets('detail screen: price, daily change and disclosures', (
    tester,
  ) async {
    await seed(tester, now: DateTime.now());
    await pumpApp(tester);

    await tester.tap(find.text('THYAO').first);
    await tester.pumpAndSettle();

    expect(find.text('Güncel fiyat'), findsOneWidget);
    expect(find.text('₺323,75'), findsOneWidget);
    expect(find.text('+%0,47'), findsOneWidget);
    expect(find.text('Ekim 2026 Trafik Sonuçları'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('without a key the portfolio shows where to enter it', (
    tester,
  ) async {
    await pumpApp(tester, key: null);

    expect(find.text('Fiyatlar için API anahtarı gerekli'), findsOneWidget);
    await tester.tap(find.text('Ayarlara git'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('allocation switches to single assets', (tester) async {
    await seed(tester, now: DateTime.now());
    await pumpApp(tester);

    expect(find.text('Borsa'), findsWidgets);
    await tester.tap(find.text('Varlık'));
    await tester.pumpAndSettle();
    expect(find.text('%100,0'), findsOneWidget);

    await unmount(tester);
  });
}
