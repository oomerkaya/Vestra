import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/domain/instrument.dart';
import 'package:capira/core/error/failure.dart';
import 'package:decimal/decimal.dart';

enum GoalKind {
  /// Total portfolio value, e.g. ₺1.000.000 or $25.000.
  portfolioValue,

  /// Quantity of one instrument, e.g. 100 gram gold or 500 THYAO.
  assetQuantity,
}

/// A savings goal. Lives on the device only.
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.kind,
    required this.target,
    this.currency,
    this.instrument,
  });

  final int id;
  final String title;
  final GoalKind kind;
  final Decimal target;

  /// [GoalKind.portfolioValue] only.
  final DisplayCurrency? currency;

  /// [GoalKind.assetQuantity] only.
  final Instrument? instrument;

  GoalDraft toDraft() => GoalDraft(
    title: title,
    kind: kind,
    target: target,
    currency: currency,
    instrument: instrument,
  );
}

/// Input for creating or editing a goal.
class GoalDraft {
  const GoalDraft({
    required this.title,
    required this.kind,
    required this.target,
    this.currency,
    this.instrument,
  });

  final String title;
  final GoalKind kind;
  final Decimal target;
  final DisplayCurrency? currency;
  final Instrument? instrument;
}

/// How far a goal is.
class GoalProgress {
  const GoalProgress({required this.current, required this.target});

  final Decimal current;
  final Decimal target;

  /// 0..1 for drawing; never above 1.
  double get fraction {
    if (target <= Decimal.zero) return 0;
    final f = (current / target).toDouble();
    return f.clamp(0, 1);
  }

  /// Percent reached, may exceed 100.
  Decimal get percent => target <= Decimal.zero
      ? Decimal.zero
      : (current * Decimal.fromInt(100) / target).toDecimal(
          scaleOnInfinitePrecision: 4,
        );

  bool get reached => current >= target;
}

enum GoalProblem { emptyTitle, nonPositiveTarget, missingInstrument }

final class GoalValidationFailure extends ValidationFailure {
  const GoalValidationFailure(this.problem);

  final GoalProblem problem;
}
