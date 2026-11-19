import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_snapshot.dart';

/// Daily portfolio values kept on the device (no request involved).
abstract interface class SnapshotRepository {
  /// Stores [portfolio] and [assets] for their day, replacing what was
  /// stored for that day before.
  Future<Result<void>> record(
    PortfolioSnapshot portfolio,
    List<AssetSnapshot> assets,
  );

  /// Every daily snapshot, oldest first, live.
  Stream<Result<List<PortfolioSnapshot>>> watchSnapshots();

  /// Instruments stored for [day].
  Future<Result<List<AssetSnapshot>>> assetsOn(String day);
}
