import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/router/app_routes.dart';
import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/utils/formatters.dart';
import 'package:capira/core/widgets/amount_display.dart';
import 'package:capira/core/widgets/collapsible_section.dart';
import 'package:capira/features/portfolio/domain/entities/goal.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:capira/features/portfolio/presentation/portfolio_labels.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Savings goals with progress bars, and a button to add one.
class GoalsSection extends ConsumerWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final goals = ref.watch(goalProgressProvider);

    return CollapsibleSection(
      title: l10n.goalsTitle,
      storageKey: 'portfolio-goals',
      trailing: goals.isEmpty ? null : '${goals.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Text(
                l10n.goalsEmpty,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          for (final (i, (goal, progress)) in goals.indexed) ...[
            if (i > 0) const Divider(),
            _GoalTile(goal: goal, progress: progress),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push(AppRoutes.newGoal),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.goalsAdd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal, required this.progress});

  final Goal goal;
  final GoalProgress? progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final format = AmountDisplay.of(context);
    final p = progress;

    return InkWell(
      onTap: () => context.push(AppRoutes.editGoal(goal.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (p != null)
                  Text(
                    p.reached
                        ? l10n.goalsReached
                        : Formatters.percent(p.percent, decimals: 0),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: p.reached ? theme.colorScheme.primary : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: LinearProgressIndicator(
                value: p?.fraction ?? 0,
                minHeight: AppSpacing.sm,
                semanticsLabel: goal.title,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              p == null
                  ? l10n.goalsNoRate
                  : format.private(_progressText(l10n, p)),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// "$1.790 / $3.000" or "5 / 25 gram".
  String _progressText(AppLocalizations l10n, GoalProgress p) {
    switch (goal.kind) {
      case GoalKind.portfolioValue:
        final symbol = (goal.currency ?? DisplayCurrency.tryLira).symbol;
        String money(Decimal v) =>
            Formatters.money(v, symbol: symbol, decimals: 0);
        return '${money(p.current)} / ${money(p.target)}';
      case GoalKind.assetQuantity:
        final i = goal.instrument;
        final unit = i == null ? '' : ' ${quantityUnit(l10n, i)}';
        return '${Formatters.number(p.current, decimals: 6)} / '
            '${Formatters.number(p.target, decimals: 6)}$unit';
    }
  }
}
