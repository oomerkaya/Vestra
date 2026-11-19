import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/app.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/di/database_provider.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/features/market/data/datasources/kap_disclosure_local_data_source.dart';
import 'package:vestra/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:vestra/features/market/data/mappers/kap_disclosure_mapper.dart';
import 'package:vestra/features/market/data/mappers/quote_mappers.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/settings/settings_providers.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';
import 'helpers/test_database.dart';

/// Every main screen must lay out without overflow at a large system font
/// size on a small phone (360 dp wide).
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<void> seed(WidgetTester tester) => tester.runAsync(() async {
    final now = DateTime.now();
    for (final (i, r) in [
      ('stock', 'THYAO', '100', '320'),
      ('currency', 'USD', '300', '41'),
      ('fund', 'TCD', '1000', '9'),
      ('gold', 'CUMHURIYET', '2', '25000'),
    ].indexed) {
      final id = await db
          .into(db.assets)
          .insert(AssetsCompanion.insert(type: r.$1, code: r.$2, name: r.$2));
      await db
          .into(db.assetTransactions)
          .insert(
            AssetTransactionsCompanion.insert(
              assetId: id,
              kind: 'buy',
              quantity: d(r.$3),
              unitPriceTry: Value(d(r.$4)),
              date: DateTime(2026, 10, 1 + i),
            ),
          );
    }
    Quote q(AssetType t, String c, String p, [String? n]) => Quote(
      instrument: (type: t, code: c),
      priceTry: d(p),
      source: QuoteSource.burkut,
      fetchedAt: now,
      name: n,
      changePercent: d('-12.34'),
    );
    await PriceCacheLocalDataSource(db).upsertAll([
      for (final x in [
        q(AssetType.stock, 'THYAO', '323.75', 'TÜRK HAVA YOLLARI A.O.'),
        q(AssetType.currency, 'USD', '42.10'),
        q(AssetType.fund, 'TCD', '9.5321', 'TACİRLER PORTFÖY DEĞİŞKEN FON'),
        q(AssetType.gold, 'CUMHURIYET', '41250.50'),
      ])
        x.toCompanion(),
    ]);
    await KapDisclosureLocalDataSource(db).storeFeed([
      KapDisclosure(
        id: '1:THYAO',
        symbol: 'THYAO',
        title: 'Özel Durum Açıklaması (Genel)',
        summary: 'Ekim 2026 Trafik Sonuçları ve uzun bir açıklama metni',
        publishedAt: now.subtract(const Duration(hours: 2)),
        url: 'https://www.kap.org.tr/tr/Bildirim/1',
      ).toCompanion(),
    ], at: now);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          autoRefreshEnabledProvider.overrideWithValue(false),
          apiKeyRepositoryProvider.overrideWithValue(
            FakeApiKeyRepository('bk_test_fake'),
          ),
        ],
        child: const VestraApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('large text: main screens without overflow', (tester) async {
    await seed(tester);
    await pumpApp(tester);
    expect(tester.takeException(), isNull, reason: 'portfolio');

    await go(tester, find.text('DAĞILIM'));
    await go(tester, find.byTooltip('KAP bildirimleri'));
    await go(tester, find.byType(BackButton));
    await go(tester, find.text('THYAO').first);
    await go(tester, find.byType(BackButton));
    await go(tester, find.text('Varlık ekle'));
    await go(tester, find.byType(BackButton));

    await go(tester, find.text('Piyasa'));
    for (final tab in ['Madenler', 'Borsa', 'Fonlar']) {
      await go(tester, find.text(tab).first);
    }
    await go(tester, find.text('Ayarlar'));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('guidelines: tap targets, labels, contrast', (tester) async {
    await seed(tester);
    await pumpApp(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    await tester.pumpAndSettle();
    final handle = tester.ensureSemantics();

    Future<void> check(String screen) async {
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }

    await check('portfolio');
    await go(tester, find.text('Piyasa'));
    await check('market');
    await go(tester, find.text('Ayarlar'));
    await check('settings');

    handle.dispose();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a database error shows an error screen, not an empty one', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          autoRefreshEnabledProvider.overrideWithValue(false),
          apiKeyRepositoryProvider.overrideWithValue(
            FakeApiKeyRepository('bk_test_fake'),
          ),
          holdingsProvider.overrideWith(
            (ref) => Stream.error(const StorageFailure('disk')),
          ),
        ],
        child: const VestraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Veriler okunamadı'), findsOneWidget);
    expect(find.text('Portföyün boş'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
