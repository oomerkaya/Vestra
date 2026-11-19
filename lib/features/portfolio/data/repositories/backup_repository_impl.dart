import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/utils/app_logger.dart';
import 'package:vestra/features/portfolio/data/backup/backup_codec.dart';
import 'package:vestra/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:vestra/features/portfolio/data/mappers/portfolio_mappers.dart';
import 'package:vestra/features/portfolio/domain/entities/asset.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_backup.dart';
import 'package:vestra/features/portfolio/domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._local, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PortfolioLocalDataSource _local;
  final DateTime Function() _clock;

  @override
  Future<Result<String>> exportBackup() async {
    try {
      final rows = await _local.getAssetsWithTransactions();
      final backup = PortfolioBackup(
        exportedAt: _clock(),
        assets: [
          for (final (assetRow, txRows) in rows)
            BackupAsset(
              asset: _draftOf(assetRow.toEntity()),
              transactions: [
                for (final tx
                    in txRows.map((r) => r.toEntity()).toList()
                      ..sort(_byDateThenId))
                  TransactionDraft(
                    kind: tx.kind,
                    quantity: tx.quantity,
                    unitPriceTry: tx.unitPriceTry,
                    date: tx.date,
                    note: tx.note,
                  ),
              ],
            ),
        ],
      );
      return Success(BackupCodec.encode(backup));
    } on Object catch (e, st) {
      AppLogger.error('backup export failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Result<PortfolioBackup> parseBackup(String content) {
    try {
      return Success(BackupCodec.decode(content));
    } on BackupFailure catch (failure) {
      return Err(failure);
    }
  }

  @override
  Future<Result<void>> replacePortfolio(PortfolioBackup backup) async {
    try {
      await _local.replaceAll([
        for (final entry in backup.assets)
          (
            type: entry.asset.type.name,
            code: entry.asset.code,
            name: entry.asset.name,
            transactions: [
              for (final tx in entry.transactions) tx.toCompanion(0),
            ],
          ),
      ]);
      return const Success(null);
    } on Object catch (e, st) {
      AppLogger.error('backup restore failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }

  static AssetDraft _draftOf(Asset a) =>
      AssetDraft(type: a.type, code: a.code, name: a.name);

  static int _byDateThenId(AssetTransaction a, AssetTransaction b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.id.compareTo(b.id);
  }
}
