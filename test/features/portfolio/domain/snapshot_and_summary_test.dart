import 'package:capira/core/database/app_database.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/portfolio/data/repositories/snapshot_repository_impl.dart';
import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/portfolio/domain/entities/holding.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_snapshot.dart';
import 'package:capira/features/portfolio/domain/services/period_summary_calculator.dart';
import 'package:capira/features/portfolio/domain/services/portfolio_valuator.dart';
import 'package:capira/features/portfolio/domain/services/snapshot_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

/// Istanbul wall-clock time as an instant (Istanbul = UTC+3).
DateTime ist(int y, int m, int d, int h, [int min = 0]) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(hours: 3));

Quote _q(AssetType type, String code, String price) => Quote(
  instrument: (type: type, code: code),
  priceTry: d(price),
  source: QuoteSource.burkut,
  fetchedAt: DateTime.utc(2026, 11, 19),
);

Holding _h(int id, AssetType type, String code, String qty) => Holding(
  asset: Asset(id: id, type: type, code: code, name: code),
  quantity: d(qty),
  transactionCount: 1,
);

PortfolioSnapshot _s(String day, String value) =>
    PortfolioSnapshot(day: day, valueTry: d(value));

AssetSnapshot _a(String day, AssetType type, String code, String price) =>
    AssetSnapshot(
      day: day,
      instrument: (type: type, code: code),
      quantity: d('1'),
      priceTry: d(price),
    );

void main() {
  final now = ist(2026, 11, 19, 12);

  test('day key is the Istanbul date', () {
    expect(SnapshotBuilder.dayKey(ist(2026, 11, 19, 0, 30)), '2026-11-19');
    expect(SnapshotBuilder.dayKey(ist(2026, 11, 18, 23, 59)), '2026-11-18');
  });

  test('snapshot holds the total, rates and every priced holding', () {
    final summary = PortfolioValuator.value(
      [
        _h(1, AssetType.stock, 'THYAO', '10'),
        _h(2, AssetType.currency, 'USD', '100'),
        _h(3, AssetType.stock, 'NOPRICE', '5'),
      ],
      [
        _q(AssetType.stock, 'THYAO', '300'),
        _q(AssetType.currency, 'USD', '42'),
        _q(AssetType.currency, 'EUR', '49'),
      ],
    );

    final (portfolio, assets) = SnapshotBuilder.build(
      summary: summary,
      quotes: [
        _q(AssetType.currency, 'USD', '42'),
        _q(AssetType.currency, 'EUR', '49'),
      ],
      now: now,
    )!;

    expect(portfolio.day, '2026-11-19');
    expect(portfolio.valueTry, d('7200'));
    expect(portfolio.usdTry, d('42'));
    expect(portfolio.eurTry, d('49'));
    expect(assets.map((a) => a.instrument.code).toSet(), {'THYAO', 'USD'});
  });

  group('base snapshot', () {
    final snapshots = [
      _s('2026-11-01', '100'),
      _s('2026-11-11', '110'),
      _s('2026-11-12', '120'),
      _s('2026-11-18', '130'),
      _s('2026-11-19', '140'),
    ];

    test('last day on or before the period start', () {
      expect(
        PeriodSummaryCalculator.baseSnapshot(
          snapshots,
          SummaryPeriod.week,
          now,
        )?.day,
        '2026-11-12',
      );
      expect(
        PeriodSummaryCalculator.baseSnapshot(
          snapshots,
          SummaryPeriod.month,
          now,
        )?.day,
        '2026-11-01',
      );
    });

    test('shorter history: the oldest day before today', () {
      expect(
        PeriodSummaryCalculator.baseSnapshot(
          [_s('2026-11-17', '1'), _s('2026-11-19', '2')],
          SummaryPeriod.month,
          now,
        )?.day,
        '2026-11-17',
      );
    });

    test('only today: nothing to compare with', () {
      expect(
        PeriodSummaryCalculator.baseSnapshot(
          [_s('2026-11-19', '2')],
          SummaryPeriod.week,
          now,
        ),
        isNull,
      );
    });
  });

  test('summary separates buying from price changes', () {
    // A week ago: THYAO 10 x 300 + ASELS 10 x 100 = 4000.
    // Since then: bought 10 more ASELS at 110 (+1100).
    // Now: THYAO 330 (+10 %), ASELS 90 (−10 %).
    final current = PortfolioValuator.value(
      [
        _h(1, AssetType.stock, 'THYAO', '10'),
        _h(2, AssetType.stock, 'ASELS', '20'),
      ],
      [
        _q(AssetType.stock, 'THYAO', '330'),
        _q(AssetType.stock, 'ASELS', '90'),
      ],
    );
    final summary = PeriodSummaryCalculator.calculate(
      period: SummaryPeriod.week,
      now: now,
      snapshots: [_s('2026-11-12', '4000'), _s('2026-11-19', '0')],
      baseAssets: [
        _a('2026-11-12', AssetType.stock, 'THYAO', '300'),
        _a('2026-11-12', AssetType.stock, 'ASELS', '100'),
      ],
      current: current,
      transactions: [
        AssetTransaction(
          id: 1,
          assetId: 2,
          kind: TransactionKind.buy,
          quantity: d('10'),
          unitPriceTry: d('110'),
          date: ist(2026, 11, 15, 11),
        ),
        // Before the base day: not part of the period.
        AssetTransaction(
          id: 2,
          assetId: 1,
          kind: TransactionKind.buy,
          quantity: d('10'),
          unitPriceTry: d('250'),
          date: ist(2026, 11, 1, 11),
        ),
      ],
    )!;

    expect(summary.endValue, d('5100')); // 3300 + 1800
    expect(summary.change, d('1100'));
    expect(summary.netInvested, d('1100'));
    expect(summary.marketEffect, d('0'));
    expect(summary.best?.instrument.code, 'THYAO');
    expect(summary.best?.changePercent, d('10'));
    expect(summary.worst?.instrument.code, 'ASELS');
    expect(summary.worst?.changePercent, d('-10'));
  });

  group('repository', () {
    late AppDatabase db;
    late SnapshotRepositoryImpl repo;

    setUp(() {
      db = createTestDatabase();
      repo = SnapshotRepositoryImpl(db);
    });
    tearDown(() => db.close());

    test('one row per day, the latest value wins', () async {
      await repo.record(_s('2026-11-18', '100'), [
        _a('2026-11-18', AssetType.stock, 'THYAO', '300'),
      ]);
      await repo.record(_s('2026-11-19', '110'), []);
      await repo.record(_s('2026-11-19', '120'), [
        _a('2026-11-19', AssetType.stock, 'THYAO', '310'),
      ]);

      final all = (await repo.watchSnapshots().first).valueOrNull!;
      expect(all.map((s) => '${s.day}=${s.valueTry}'), [
        '2026-11-18=100',
        '2026-11-19=120',
      ]);
      final assets = (await repo.assetsOn('2026-11-19')).valueOrNull!;
      expect(assets.single.priceTry, d('310'));
    });
  });
}
