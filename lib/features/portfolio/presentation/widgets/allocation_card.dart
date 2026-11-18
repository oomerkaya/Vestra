import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/theme/app_typography.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/donut_chart.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/portfolio/presentation/portfolio_labels.dart';

/// Donut + legend: share of each category in the total value.
class AllocationCard extends StatelessWidget {
  const AllocationCard({
    required this.valueByCategory,
    required this.total,
    super.key,
  });

  final Map<QuoteCategory, Decimal> valueByCategory;
  final Decimal total;

  static final Decimal _hundred = Decimal.fromInt(100);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final entries = [
      for (final c in QuoteCategory.values)
        if ((valueByCategory[c] ?? Decimal.zero) > Decimal.zero)
          (category: c, value: valueByCategory[c]!),
    ];
    // Percent computed with Decimal; converted to double only for drawing.
    final percents = {
      for (final e in entries)
        e.category: (e.value * _hundred / total).toDecimal(
          scaleOnInfinitePrecision: 4,
        ),
    };

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          DonutChart(
            size: 120,
            thickness: 16,
            semanticsLabel: [
              for (final e in entries)
                _legendLabel(l10n, e.category, percents[e.category]!),
            ].join(', '),
            segments: [
              for (final e in entries)
                DonutSegment(
                  fraction: percents[e.category]!.toDouble() / 100,
                  color: categoryColor(e.category),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, e) in entries.indexed) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: categoryColor(e.category),
                          borderRadius: AppRadius.pillAll,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          categoryLabel(l10n, e.category),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        Formatters.percent(percents[e.category]!, decimals: 1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: AppTypography.tabular,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _legendLabel(AppLocalizations l10n, QuoteCategory c, Decimal percent) =>
    [
      categoryLabel(l10n, c),
      Formatters.percent(percent, decimals: 0),
    ].join(' ');
