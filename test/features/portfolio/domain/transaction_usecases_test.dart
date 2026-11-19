import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/portfolio/domain/entities/transaction_validation_failure.dart';
import 'package:capira/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:capira/features/portfolio/domain/usecases/add_transaction.dart';
import 'package:capira/features/portfolio/domain/usecases/delete_transaction.dart';
import 'package:capira/features/portfolio/domain/usecases/update_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockRepo extends Mock implements PortfolioRepository {}

TransactionValidationReason? _reason(Result<Object?> r) => switch (r) {
  Err(failure: TransactionValidationFailure(:final reason)) => reason,
  _ => null,
};

void main() {
  const buy = TransactionKind.buy;
  const sell = TransactionKind.sell;
  late _MockRepo repo;

  setUpAll(() {
    registerFallbackValue(usdDraft);
    registerFallbackValue(draft(kind: buy, qty: '1'));
    registerFallbackValue(tx(id: 0, kind: buy, qty: '1'));
  });

  setUp(() {
    repo = _MockRepo();
    when(
      () => repo.findOrCreateAsset(any()),
    ).thenAnswer((_) async => const Success(usd));
    when(
      () => repo.insertTransaction(any(), any()),
    ).thenAnswer((_) async => const Success(42));
    when(
      () => repo.updateTransaction(any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repo.deleteTransaction(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  void givenHistory(List<AssetTransaction> history) => when(
    () => repo.getTransactions(any()),
  ).thenAnswer((_) async => Success(history));

  group('AddTransaction', () {
    late AddTransaction add;
    setUp(() => add = AddTransaction(repo));

    test('first buy creates asset and inserts', () async {
      givenHistory([]);

      final result = await add(usdDraft, draft(kind: buy, qty: '100'));

      expect(result.valueOrNull, 42);
      verify(() => repo.findOrCreateAsset(usdDraft)).called(1);
      verify(() => repo.insertTransaction(usd.id, any())).called(1);
    });

    test('rejects zero quantity without touching the repository', () async {
      final result = await add(usdDraft, draft(kind: buy, qty: '0'));

      expect(_reason(result), TransactionValidationReason.nonPositiveQuantity);
      verifyZeroInteractions(repo);
    });

    test('rejects negative price', () async {
      final result = await add(
        usdDraft,
        draft(kind: buy, qty: '1', price: '-1'),
      );

      expect(_reason(result), TransactionValidationReason.negativePrice);
    });

    test('rejects selling more than held', () async {
      givenHistory([tx(id: 1, kind: buy, qty: '10')]);

      final result = await add(usdDraft, draft(kind: sell, qty: '11'));

      expect(_reason(result), TransactionValidationReason.oversell);
      verifyNever(() => repo.insertTransaction(any(), any()));
    });

    test('rejects backdated sell before the first buy', () async {
      givenHistory([
        tx(id: 1, kind: buy, qty: '10', date: DateTime(2026, 6)),
      ]);

      final result = await add(
        usdDraft,
        draft(kind: sell, qty: '1', date: DateTime(2026, 5)),
      );

      expect(_reason(result), TransactionValidationReason.oversell);
    });

    test('allows selling exactly what is held', () async {
      givenHistory([tx(id: 1, kind: buy, qty: '10')]);

      final result = await add(usdDraft, draft(kind: sell, qty: '10'));

      expect(result.isSuccess, isTrue);
    });

    test('propagates repository failures', () async {
      when(
        () => repo.findOrCreateAsset(any()),
      ).thenAnswer((_) async => const Err(StorageFailure()));

      final result = await add(usdDraft, draft(kind: buy, qty: '1'));

      expect(result, isA<Err<int>>());
    });
  });

  group('UpdateTransaction', () {
    test('rejects lowering a buy below later sells', () async {
      givenHistory([
        tx(id: 1, kind: buy, qty: '10'),
        tx(id: 2, kind: sell, qty: '8'),
      ]);
      final updated = tx(id: 1, kind: buy, qty: '5');

      final result = await UpdateTransaction(repo)(updated);

      expect(_reason(result), TransactionValidationReason.oversell);
      verifyNever(() => repo.updateTransaction(any()));
    });

    test('saves a valid change', () async {
      givenHistory([tx(id: 1, kind: buy, qty: '10')]);

      final result = await UpdateTransaction(
        repo,
      )(tx(id: 1, kind: buy, qty: '12', price: '35'));

      expect(result.isSuccess, isTrue);
      verify(() => repo.updateTransaction(any())).called(1);
    });
  });

  group('DeleteTransaction', () {
    test('rejects deleting the buy that covers a sell', () async {
      final buyTx = tx(id: 1, kind: buy, qty: '10');
      givenHistory([buyTx, tx(id: 2, kind: sell, qty: '4')]);

      final result = await DeleteTransaction(repo)(buyTx);

      expect(_reason(result), TransactionValidationReason.oversell);
      verifyNever(() => repo.deleteTransaction(any()));
    });

    test('deletes a sell freely', () async {
      final sellTx = tx(id: 2, kind: sell, qty: '4');
      givenHistory([tx(id: 1, kind: buy, qty: '10'), sellTx]);

      final result = await DeleteTransaction(repo)(sellTx);

      expect(result.isSuccess, isTrue);
      verify(() => repo.deleteTransaction(2)).called(1);
    });
  });
}
