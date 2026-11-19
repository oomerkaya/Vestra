import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_backup.dart';

/// Reads and writes portfolio backups. The file format is the data layer's
/// business; the domain only sees [PortfolioBackup].
abstract interface class BackupRepository {
  /// The current portfolio as backup file content.
  Future<Result<String>> exportBackup();

  /// Parses backup file content (no validation of the values themselves).
  Result<PortfolioBackup> parseBackup(String content);

  /// Deletes every asset and transaction and stores [backup] instead, in
  /// one database transaction.
  Future<Result<void>> replacePortfolio(PortfolioBackup backup);
}
