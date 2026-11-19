import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_backup.dart';
import 'package:vestra/features/portfolio/domain/repositories/backup_repository.dart';
import 'package:vestra/features/portfolio/domain/usecases/transaction_validator.dart';

/// The current portfolio as backup file content.
class ExportPortfolio {
  const ExportPortfolio(this._repository);

  final BackupRepository _repository;

  Future<Result<String>> call() => _repository.exportBackup();
}

/// Reads a backup file and checks it fully before anything is changed, so
/// the user can confirm what will be restored.
class ReadBackup {
  const ReadBackup(this._repository);

  final BackupRepository _repository;

  Result<PortfolioBackup> call(String content) {
    final parsed = _repository.parseBackup(content);
    if (parsed case Success(value: final backup)) {
      final problem = validate(backup);
      if (problem != null) return Err(problem);
    }
    return parsed;
  }

  /// Same rules as entering transactions by hand: no empty codes, no
  /// duplicate assets, positive quantities, no negative prices and never
  /// selling more than held.
  static BackupFailure? validate(PortfolioBackup backup) {
    final seen = <(Object, String)>{};
    for (final entry in backup.assets) {
      final asset = entry.asset;
      if (asset.code.trim().isEmpty ||
          !seen.add((asset.type, asset.code.toUpperCase()))) {
        return const BackupFailure(BackupProblem.invalidData);
      }
      final history = <AssetTransaction>[];
      for (final (i, tx) in entry.transactions.indexed) {
        if (TransactionValidator.validateFields(
              quantity: tx.quantity,
              unitPriceTry: tx.unitPriceTry,
            ) !=
            null) {
          return const BackupFailure(BackupProblem.invalidData);
        }
        history.add(
          AssetTransaction(
            id: i,
            assetId: 0,
            kind: tx.kind,
            quantity: tx.quantity,
            unitPriceTry: tx.unitPriceTry,
            date: tx.date,
          ),
        );
      }
      if (TransactionValidator.validateHistory(history) != null) {
        return const BackupFailure(BackupProblem.invalidData);
      }
    }
    return null;
  }
}

/// Replaces the whole portfolio with a backup read by [ReadBackup].
class RestoreBackup {
  const RestoreBackup(this._repository);

  final BackupRepository _repository;

  Future<Result<void>> call(PortfolioBackup backup) {
    final problem = ReadBackup.validate(backup);
    if (problem != null) return Future.value(Err(problem));
    return _repository.replacePortfolio(backup);
  }
}
