import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/domain/instrument.dart';
import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/core/utils/app_logger.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_snapshot.dart';
import 'package:capira/features/portfolio/domain/repositories/snapshot_repository.dart';
import 'package:drift/drift.dart';

/// Drift-backed daily snapshots (`portfolio_snapshots`, `asset_snapshots`).
class SnapshotRepositoryImpl implements SnapshotRepository {
  SnapshotRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<Result<void>> record(
    PortfolioSnapshot portfolio,
    List<AssetSnapshot> assets,
  ) async {
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.portfolioSnapshots)
            .insertOnConflictUpdate(
              PortfolioSnapshotsCompanion.insert(
                day: portfolio.day,
                valueTry: portfolio.valueTry,
                costTry: Value(portfolio.costTry),
                usdTry: Value(portfolio.usdTry),
                eurTry: Value(portfolio.eurTry),
                updatedAt: _clock(),
              ),
            );
        await (_db.delete(
          _db.assetSnapshots,
        )..where((t) => t.day.equals(portfolio.day))).go();
        await _db.batch(
          (b) => b.insertAll(_db.assetSnapshots, [
            for (final a in assets)
              AssetSnapshotsCompanion.insert(
                day: a.day,
                type: a.instrument.type.name,
                code: a.instrument.code,
                quantity: a.quantity,
                priceTry: a.priceTry,
              ),
          ]),
        );
      });
      return const Success(null);
    } on Object catch (e, st) {
      AppLogger.error('snapshot record failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Stream<Result<List<PortfolioSnapshot>>> watchSnapshots() async* {
    try {
      final query = _db.select(_db.portfolioSnapshots)
        ..orderBy([(t) => OrderingTerm.asc(t.day)]);
      await for (final rows in query.watch()) {
        yield Success([
          for (final r in rows)
            PortfolioSnapshot(
              day: r.day,
              valueTry: r.valueTry,
              costTry: r.costTry,
              usdTry: r.usdTry,
              eurTry: r.eurTry,
            ),
        ]);
      }
    } on Object catch (e, st) {
      AppLogger.error('snapshot watch failed', error: e, stackTrace: st);
      yield Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AssetSnapshot>>> assetsOn(String day) async {
    try {
      final rows = await (_db.select(
        _db.assetSnapshots,
      )..where((t) => t.day.equals(day))).get();
      return Success([
        for (final r in rows)
          if (AssetType.values.where((t) => t.name == r.type).firstOrNull
              case final type?)
            AssetSnapshot(
              day: r.day,
              instrument: (type: type, code: r.code),
              quantity: r.quantity,
              priceTry: r.priceTry,
            ),
      ]);
    } on Object catch (e, st) {
      AppLogger.error('snapshot read failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }
}
