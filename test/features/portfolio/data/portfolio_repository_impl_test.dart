import 'package:capira/core/database/app_database.dart';
import 'package:capira/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:capira/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/portfolio/domain/usecases/watch_holdings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late PortfolioRepositoryImpl repo;

  setUp(() {
    db = createTestDatabase();
    repo = PortfolioRepositoryImpl(PortfolioLocalDataSource(db));
  });

  tearDown(() => db.close());

  test('findOrCreateAsset is idempotent per (type, code)', () async {
    final first = (await repo.findOrCreateAsset(usdDraft)).valueOrNull!;
    final second = (await repo.findOrCreateAsset(usdDraft)).valueOrNull!;
    final gold = (await repo.findOrCreateAsset(gramGoldDraft)).valueOrNull!;

    expect(second.id, first.id);
    expect(gold.id, isNot(first.id));
    expect(gold.type, AssetType.gold);
  });

  test('decimal values round-trip exactly', () async {
    final asset = (await repo.findOrCreateAsset(gramGoldDraft)).valueOrNull!;
    await repo.insertTransaction(
      asset.id,
      draft(
        kind: TransactionKind.buy,
        qty: '0.123456789',
        price: '3456.78',
      ),
    );

    final txs = (await repo.getTransactions(asset.id)).valueOrNull!;

    expect(txs.single.quantity, d('0.123456789'));
    expect(txs.single.unitPriceTry, d('3456.78'));
    expect(txs.single.kind, TransactionKind.buy);
  });

  test('null price is stored as null', () async {
    final asset = (await repo.findOrCreateAsset(usdDraft)).valueOrNull!;
    await repo.insertTransaction(
      asset.id,
      draft(kind: TransactionKind.buy, qty: '1'),
    );

    final txs = (await repo.getTransactions(asset.id)).valueOrNull!;
    expect(txs.single.unitPriceTry, isNull);
  });

  test('update and delete transaction', () async {
    final asset = (await repo.findOrCreateAsset(usdDraft)).valueOrNull!;
    final id = (await repo.insertTransaction(
      asset.id,
      draft(kind: TransactionKind.buy, qty: '1', price: '30'),
    )).valueOrNull!;
    final original = (await repo.getTransactions(asset.id)).valueOrNull!.single;

    await repo.updateTransaction(original.copyWith(quantity: d('2')));
    final updated = (await repo.getTransactions(asset.id)).valueOrNull!.single;
    expect(updated.id, id);
    expect(updated.quantity, d('2'));

    await repo.deleteTransaction(id);
    expect((await repo.getTransactions(asset.id)).valueOrNull, isEmpty);
  });

  test('updating a missing transaction fails', () async {
    final result = await repo.updateTransaction(
      tx(id: 999, kind: TransactionKind.buy, qty: '1'),
    );
    expect(result.isFailure, isTrue);
  });

  test('deleting an asset cascades to its transactions', () async {
    final asset = (await repo.findOrCreateAsset(usdDraft)).valueOrNull!;
    await repo.insertTransaction(
      asset.id,
      draft(kind: TransactionKind.buy, qty: '1'),
    );

    await repo.deleteAsset(asset.id);

    final remaining = await db.select(db.assetTransactions).get();
    expect(remaining, isEmpty);
  });

  test('transaction for unknown asset violates foreign key', () async {
    final result = await repo.insertTransaction(
      12345,
      draft(kind: TransactionKind.buy, qty: '1'),
    );
    expect(result.isFailure, isTrue);
  });

  test('WatchHoldings emits recalculated holdings on change', () async {
    final asset = (await repo.findOrCreateAsset(usdDraft)).valueOrNull!;
    final stream = WatchHoldings(repo)();

    final expectation = expectLater(
      stream.map((r) => r.valueOrNull!.single.quantity.toString()),
      emitsInOrder(['0', '10', '7']),
    );

    await pumpEventQueue();
    await repo.insertTransaction(
      asset.id,
      draft(kind: TransactionKind.buy, qty: '10', price: '30'),
    );
    await pumpEventQueue();
    await repo.insertTransaction(
      asset.id,
      draft(kind: TransactionKind.sell, qty: '3', price: '35'),
    );

    await expectation;
  });
}
