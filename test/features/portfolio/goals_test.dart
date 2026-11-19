import 'package:capira/app.dart';
import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/di/database_provider.dart';
import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/features/market/data/datasources/price_cache_local_data_source.dart';
import 'package:capira/features/market/data/mappers/quote_mappers.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:capira/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:capira/features/portfolio/data/repositories/goal_repository_impl.dart';
import 'package:capira/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/portfolio/domain/entities/goal.dart';
import 'package:capira/features/portfolio/domain/entities/holding.dart';
import 'package:capira/features/portfolio/domain/services/goal_calculator.dart';
import 'package:capira/features/portfolio/domain/services/portfolio_valuator.dart';
import 'package:capira/features/portfolio/domain/usecases/goal_use_cases.dart';
import 'package:capira/features/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_database.dart';

Quote _q(AssetType type, String code, String price) => Quote(
  instrument: (type: type, code: code),
  priceTry: d(price),
  source: QuoteSource.burkut,
  fetchedAt: DateTime.now(),
);

void main() {
  final summary = PortfolioValuator.value(
    [
      Holding(
        asset: const Asset(
          id: 1,
          type: AssetType.gold,
          code: 'GRAM',
          name: 'GRAM',
        ),
        quantity: d('25'),
        transactionCount: 1,
      ),
    ],
    [_q(AssetType.gold, 'GRAM', '6000')],
  ); // 150.000 TL

  group('progress', () {
    test('quantity goal counts the held amount', () {
      final p = GoalCalculator.progress(
        Goal(
          id: 1,
          title: '100 gram',
          kind: GoalKind.assetQuantity,
          target: d('100'),
          instrument: (type: AssetType.gold, code: 'GRAM'),
        ),
        summary,
      )!;
      expect(p.current, d('25'));
      expect(p.percent, d('25'));
      expect(p.reached, isFalse);
    });

    test('value goal in dollars uses the rate', () {
      final goal = Goal(
        id: 2,
        title: r'5.000 $',
        kind: GoalKind.portfolioValue,
        target: d('5000'),
        currency: DisplayCurrency.usd,
      );
      expect(GoalCalculator.progress(goal, summary), isNull, reason: 'no rate');
      final p = GoalCalculator.progress(goal, summary, usdTry: d('30'))!;
      expect(p.current, d('5000'));
      expect(p.reached, isTrue);
      expect(p.fraction, 1);
    });

    test('validation', () {
      expect(
        GoalCalculator.validate(
          GoalDraft(title: ' ', kind: GoalKind.portfolioValue, target: d('1')),
        )?.problem,
        GoalProblem.emptyTitle,
      );
      expect(
        GoalCalculator.validate(
          GoalDraft(title: 'x', kind: GoalKind.portfolioValue, target: d('0')),
        )?.problem,
        GoalProblem.nonPositiveTarget,
      );
      expect(
        GoalCalculator.validate(
          GoalDraft(title: 'x', kind: GoalKind.assetQuantity, target: d('1')),
        )?.problem,
        GoalProblem.missingInstrument,
      );
    });
  });

  group('repository', () {
    late AppDatabase db;

    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    test('save, edit and delete', () async {
      final repo = GoalRepositoryImpl(db);
      final save = SaveGoal(repo);
      final id = (await save(
        GoalDraft(
          title: '  Altın  ',
          kind: GoalKind.assetQuantity,
          target: d('100'),
          currency: DisplayCurrency.usd, // dropped for quantity goals
          instrument: (type: AssetType.gold, code: 'GRAM'),
        ),
      )).valueOrNull!;

      var goals = (await repo.watchGoals().first).valueOrNull!;
      expect(goals.single.title, 'Altın');
      expect(goals.single.currency, isNull);
      expect(goals.single.instrument, (type: AssetType.gold, code: 'GRAM'));

      await save(goals.single.toDraft(), id: id);
      await save(
        GoalDraft(title: 'Ev', kind: GoalKind.portfolioValue, target: d('2')),
        id: id,
      );
      goals = (await repo.watchGoals().first).valueOrNull!;
      expect(goals.single.kind, GoalKind.portfolioValue);
      expect(goals.single.instrument, isNull);

      await DeleteGoal(repo)(id);
      expect((await repo.watchGoals().first).valueOrNull, isEmpty);
    });
  });

  testWidgets('add a value goal from the portfolio screen', (tester) async {
    final db = createTestDatabase();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      final portfolio = PortfolioRepositoryImpl(PortfolioLocalDataSource(db));
      final usd = (await portfolio.findOrCreateAsset(usdDraft)).valueOrNull!;
      await portfolio.insertTransaction(
        usd.id,
        draft(kind: TransactionKind.buy, qty: '100', price: '40'),
      );
      await PriceCacheLocalDataSource(
        db,
      ).upsertAll([_q(AssetType.currency, 'USD', '42').toCompanion()]);
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

    await tester.tap(find.text('Hedef ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Hedef adı'),
      'Tatil',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Hedef tutar'),
      '8.400',
    );
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Hedef kaydedildi'), findsOneWidget);
    expect(find.text('Tatil'), findsOneWidget);
    expect(find.text('%50'), findsOneWidget); // 4.200 of 8.400
    expect(find.text('₺4.200 / ₺8.400'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });
}
