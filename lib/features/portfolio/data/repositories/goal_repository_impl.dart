import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/domain/instrument.dart';
import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/core/utils/app_logger.dart';
import 'package:capira/features/portfolio/domain/entities/goal.dart';
import 'package:capira/features/portfolio/domain/repositories/goal_repository.dart';
import 'package:drift/drift.dart';

/// Drift-backed goals (`goals`). Enum values are stored by name.
class GoalRepositoryImpl implements GoalRepository {
  const GoalRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<Result<List<Goal>>> watchGoals() async* {
    try {
      final query = _db.select(_db.goals)
        ..orderBy([(t) => OrderingTerm.asc(t.id)]);
      await for (final rows in query.watch()) {
        yield Success([for (final r in rows) ?_toEntity(r)]);
      }
    } on Object catch (e, st) {
      AppLogger.error('goals watch failed', error: e, stackTrace: st);
      yield Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> save(GoalDraft draft, {int? id}) async {
    final companion = GoalsCompanion(
      title: Value(draft.title),
      kind: Value(draft.kind.name),
      target: Value(draft.target),
      currency: Value(draft.currency?.name),
      assetType: Value(draft.instrument?.type.name),
      assetCode: Value(draft.instrument?.code),
    );
    try {
      if (id == null) {
        return Success(await _db.into(_db.goals).insert(companion));
      }
      await (_db.update(
        _db.goals,
      )..where((t) => t.id.equals(id))).write(companion);
      return Success(id);
    } on Object catch (e, st) {
      AppLogger.error('goal save failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();
      return const Success(null);
    } on Object catch (e, st) {
      AppLogger.error('goal delete failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }

  /// `null` for a row this app version cannot read (unknown enum name).
  static Goal? _toEntity(GoalRow r) {
    final kind = GoalKind.values.where((k) => k.name == r.kind).firstOrNull;
    if (kind == null) return null;
    final type = AssetType.values
        .where((t) => t.name == r.assetType)
        .firstOrNull;
    final code = r.assetCode;
    return Goal(
      id: r.id,
      title: r.title,
      kind: kind,
      target: r.target,
      currency: DisplayCurrency.values
          .where((c) => c.name == r.currency)
          .firstOrNull,
      instrument: type == null || code == null
          ? null
          : (type: type, code: code),
    );
  }
}
