import 'dart:async';

import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/utils/app_logger.dart';
import 'package:vestra/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:vestra/features/portfolio/data/mappers/portfolio_mappers.dart';
import 'package:vestra/features/portfolio/domain/entities/asset.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/holding.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  const PortfolioRepositoryImpl(this._local);

  final PortfolioLocalDataSource _local;

  @override
  Stream<Result<List<AssetWithTransactions>>> watchPortfolio() => _local
      .watchAssetsWithTransactions()
      .map<Result<List<AssetWithTransactions>>>(
        (rows) => Success([
          for (final (asset, txs) in rows)
            AssetWithTransactions(
              asset: asset.toEntity(),
              transactions: [for (final tx in txs) tx.toEntity()],
            ),
        ]),
      )
      .transform(
        StreamTransformer.fromHandlers(
          handleError: (error, stackTrace, sink) {
            AppLogger.error(
              'watchPortfolio failed',
              error: error,
              stackTrace: stackTrace,
            );
            sink.add(Err(StorageFailure(error.toString())));
          },
        ),
      );

  @override
  Future<Result<List<AssetTransaction>>> getTransactions(int assetId) => _guard(
    'getTransactions',
    () async => [
      for (final row in await _local.getTransactions(assetId)) row.toEntity(),
    ],
  );

  @override
  Future<Result<Asset>> findOrCreateAsset(AssetDraft draft) => _guard(
    'findOrCreateAsset',
    () async => (await _local.findOrCreateAsset(
      type: draft.type.name,
      code: draft.code,
      name: draft.name,
    )).toEntity(),
  );

  @override
  Future<Result<int>> insertTransaction(int assetId, TransactionDraft draft) =>
      _guard(
        'insertTransaction',
        () => _local.insertTransaction(draft.toCompanion(assetId)),
      );

  @override
  Future<Result<void>> updateTransaction(AssetTransaction transaction) =>
      _guard('updateTransaction', () async {
        final count = await _local.updateTransaction(
          transaction.id,
          transaction.toUpdateCompanion(),
        );
        if (count == 0) {
          throw StateError('transaction ${transaction.id} not found');
        }
      });

  @override
  Future<Result<void>> deleteTransaction(int transactionId) => _guard(
    'deleteTransaction',
    () => _local.deleteTransaction(transactionId),
  );

  @override
  Future<Result<void>> deleteAsset(int assetId) =>
      _guard('deleteAsset', () => _local.deleteAsset(assetId));

  Future<Result<T>> _guard<T>(String op, Future<T> Function() body) async {
    try {
      return Success(await body());
    } on Object catch (error, stackTrace) {
      AppLogger.error('$op failed', error: error, stackTrace: stackTrace);
      return Err(StorageFailure('$op: $error'));
    }
  }
}
