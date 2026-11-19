import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/entities/goal.dart';
import 'package:capira/features/portfolio/domain/repositories/goal_repository.dart';
import 'package:capira/features/portfolio/domain/services/goal_calculator.dart';

/// Validates and stores a new or edited goal.
class SaveGoal {
  const SaveGoal(this._repository);

  final GoalRepository _repository;

  Future<Result<int>> call(GoalDraft draft, {int? id}) {
    final problem = GoalCalculator.validate(draft);
    if (problem != null) return Future.value(Err(problem));
    return _repository.save(
      GoalDraft(
        title: draft.title.trim(),
        kind: draft.kind,
        target: draft.target,
        currency: draft.kind == GoalKind.portfolioValue ? draft.currency : null,
        instrument: draft.kind == GoalKind.assetQuantity
            ? draft.instrument
            : null,
      ),
      id: id,
    );
  }
}

class DeleteGoal {
  const DeleteGoal(this._repository);

  final GoalRepository _repository;

  Future<Result<void>> call(int id) => _repository.delete(id);
}
