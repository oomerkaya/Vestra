import 'package:capira/core/error/failure.dart';
import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';

/// One asset with its transactions, as stored in a backup.
class BackupAsset {
  const BackupAsset({required this.asset, required this.transactions});

  final AssetDraft asset;
  final List<TransactionDraft> transactions;
}

/// The whole portfolio (assets and transactions only). Prices, KAP
/// disclosures, settings and the API key are never part of a backup.
class PortfolioBackup {
  const PortfolioBackup({required this.exportedAt, required this.assets});

  final DateTime exportedAt;
  final List<BackupAsset> assets;

  int get transactionCount =>
      assets.fold(0, (sum, a) => sum + a.transactions.length);
}

enum BackupProblem {
  /// Not JSON or not a Capira (or Vestra) backup at all.
  notABackup,

  /// Written by a newer app version.
  newerFormat,

  /// Readable, but values are missing or inconsistent (e.g. a sale larger
  /// than the holding).
  invalidData,
}

final class BackupFailure extends ValidationFailure {
  const BackupFailure(this.problem, [super.message]);

  final BackupProblem problem;
}
