import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/entities/goal.dart';

abstract interface class GoalRepository {
  /// Every goal, oldest first, live.
  Stream<Result<List<Goal>>> watchGoals();

  /// Inserts when [id] is `null`, else updates. Returns the goal's id.
  Future<Result<int>> save(GoalDraft draft, {int? id});

  Future<Result<void>> delete(int id);
}
