import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/features/portfolio/domain/entities/goal.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:decimal/decimal.dart';

/// Pure goal checks and progress.
abstract final class GoalCalculator {
  static GoalValidationFailure? validate(GoalDraft draft) {
    if (draft.title.trim().isEmpty) {
      return const GoalValidationFailure(GoalProblem.emptyTitle);
    }
    if (draft.target <= Decimal.zero) {
      return const GoalValidationFailure(GoalProblem.nonPositiveTarget);
    }
    if (draft.kind == GoalKind.assetQuantity && draft.instrument == null) {
      return const GoalValidationFailure(GoalProblem.missingInstrument);
    }
    return null;
  }

  /// `null` when a value goal's currency has no known rate.
  static GoalProgress? progress(
    Goal goal,
    PortfolioSummary summary, {
    Decimal? usdTry,
    Decimal? eurTry,
  }) {
    switch (goal.kind) {
      case GoalKind.assetQuantity:
        final held = summary.holdings
            .where(
              (v) =>
                  v.holding.asset.type == goal.instrument?.type &&
                  v.holding.asset.code == goal.instrument?.code,
            )
            .fold(Decimal.zero, (sum, v) => sum + v.holding.quantity);
        return GoalProgress(current: held, target: goal.target);
      case GoalKind.portfolioValue:
        final rate = switch (goal.currency ?? DisplayCurrency.tryLira) {
          DisplayCurrency.tryLira => Decimal.one,
          DisplayCurrency.usd => usdTry,
          DisplayCurrency.eur => eurTry,
        };
        if (rate == null || rate == Decimal.zero) return null;
        return GoalProgress(
          current: (summary.totalValue / rate).toDecimal(
            scaleOnInfinitePrecision: 6,
          ),
          target: goal.target,
        );
    }
  }
}
