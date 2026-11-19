import 'package:capira/app.dart';
import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/di/database_provider.dart';
import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/widgets/amount_display.dart';
import 'package:capira/core/widgets/money_text.dart';
import 'package:capira/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:capira/features/market/data/mappers/quote_mappers.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:capira/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:capira/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

void main() {
  group('AmountFormat', () {
    test('converts TRY with the rate, keeps costs in TRY', () {
      final usd = AmountFormat(
        currency: DisplayCurrency.usd,
        rateTry: d('42'),
      );
      expect(usd.money(d('4200')), r'$100,00');
      expect(usd.signedMoney(d('-84')), r'−$2,00');
      expect(usd.money(d('320'), convert: false), '₺320,00');
    });

    test('privacy mode masks amounts and other personal figures', () {
      const hidden = AmountFormat(hidden: true);
      expect(hidden.money(d('1234')), '₺•••••');
      expect(hidden.private('100 adet'), '•••••');
    });

    test('without a rate it stays in TRY', () {
      const noRate = AmountFormat(currency: DisplayCurrency.eur);
      expect(noRate.converts, isFalse);
      expect(noRate.money(d('10')), '₺10,00');
    });
  });

  group('portfolio screen', () {
    late AppDatabase db;

    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    Future<void> pumpApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        final portfolio = PortfolioRepositoryImpl(
          PortfolioLocalDataSource(db),
        );
        final usd = (await portfolio.findOrCreateAsset(usdDraft)).valueOrNull!;
        await portfolio.insertTransaction(
          usd.id,
          draft(kind: TransactionKind.buy, qty: '100', price: '40'),
        );
        await PriceCacheLocalDataSource(db).upsertAll([
          Quote(
            instrument: (type: AssetType.currency, code: 'USD'),
            priceTry: d('42'),
            source: QuoteSource.burkut,
            fetchedAt: DateTime.now(),
          ).toCompanion(),
        ]);
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            autoRefreshEnabledProvider.overrideWithValue(false),
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

    String totalText(WidgetTester tester) {
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(MoneyText),
          matching: find.byType(Text),
        ),
      );
      return text.data ?? text.textSpan!.toPlainText();
    }

    testWidgets('the eye hides and shows personal amounts', (tester) async {
      await pumpApp(tester);
      expect(totalText(tester), '₺4.200,00');
      expect(find.textContaining('100 USD'), findsOneWidget);

      await tester.tap(find.byTooltip('Tutarları gizle'));
      await tester.pumpAndSettle();
      expect(totalText(tester), '₺•••••');
      expect(find.textContaining('100 USD'), findsNothing);
      expect(find.byTooltip('Tutarları göster'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('totals switch to dollars at the cached rate', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text(r'$'));
      await tester.pumpAndSettle();

      expect(totalText(tester), r'$100,00');
      expect(find.textContaining(r'1 $ = ₺42,00'), findsOneWidget);

      await unmount(tester);
    });
  });
}
