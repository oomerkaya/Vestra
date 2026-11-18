import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/change_chip.dart';
import 'package:vestra/core/widgets/money_text.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_summary.dart';

/// Total value, unrealized P/L and today's change.
class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({required this.summary, super.key});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final pnl = summary.unrealizedPnl;
    final daily = summary.dailyChange;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.portfolioTotalValue, style: text.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          MoneyText(
            summary.totalValue,
            style: text.displaySmall,
            emphasizeInteger: true,
          ),
          if (pnl != null || daily != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.md,
              children: [
                if (pnl != null)
                  _Metric(
                    label: l10n.portfolioPnl,
                    amount: pnl,
                    percent: summary.unrealizedPnlPercent,
                  ),
                if (daily != null)
                  _Metric(
                    label: l10n.portfolioToday,
                    amount: daily,
                    percent: summary.dailyChangePercent,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.amount, this.percent});

  final String label;
  final Decimal amount;
  final Decimal? percent;

  @override
  Widget build(BuildContext context) {
    final p = percent;
    final chipLabel = p == null
        ? Formatters.signedCurrencyTry(amount)
        : '${Formatters.signedCurrencyTry(amount)} '
              '(${Formatters.percent(p, signed: true)})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        ChangeChip(label: chipLabel, direction: directionOf(amount)),
      ],
    );
  }
}

ChangeDirection directionOf(Decimal value) {
  final rounded = value.round(scale: 2);
  if (rounded > Decimal.zero) return ChangeDirection.up;
  if (rounded < Decimal.zero) return ChangeDirection.down;
  return ChangeDirection.flat;
}
