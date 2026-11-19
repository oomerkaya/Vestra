import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/theme/app_colors.dart';
import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/theme/app_typography.dart';
import 'package:capira/core/utils/formatters.dart';
import 'package:capira/core/widgets/donut_chart.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:capira/features/portfolio/presentation/portfolio_labels.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

enum AllocationMode { category, asset }

/// One slice of the allocation chart.
typedef AllocationSlice = ({String label, Color color, Decimal value});

/// Allocation by asset type or by single asset, switchable. Content only;
/// the portfolio screen puts it in a collapsible section.
class AllocationView extends StatefulWidget {
  const AllocationView({required this.summary, super.key});

  final PortfolioSummary summary;

  /// By asset: the largest holdings get their own slice, the rest is
  /// grouped as "Diğer".
  static const int maxAssetSlices = 5;

  @override
  State<AllocationView> createState() => _AllocationViewState();
}

class _AllocationViewState extends State<AllocationView> {
  AllocationMode _mode = AllocationMode.category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = widget.summary;
    final slices = switch (_mode) {
      AllocationMode.category => [
        for (final c in QuoteCategory.values)
          if ((summary.valueByCategory[c] ?? Decimal.zero) > Decimal.zero)
            (
              label: categoryLabel(l10n, c),
              color: categoryColor(c),
              value: summary.valueByCategory[c]!,
            ),
      ],
      AllocationMode.asset => _assetSlices(context, summary),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            0,
          ),
          child: SegmentedButton<AllocationMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: AllocationMode.category,
                label: Text(l10n.allocationByCategory),
              ),
              ButtonSegment(
                value: AllocationMode.asset,
                label: Text(l10n.allocationByAsset),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.single),
          ),
        ),
        AllocationChart(slices: slices, total: summary.totalValue),
      ],
    );
  }

  List<AllocationSlice> _assetSlices(
    BuildContext context,
    PortfolioSummary summary,
  ) {
    final l10n = context.l10n;
    // Holdings are sorted by value, highest first.
    final priced = [
      for (final v in summary.holdings)
        if ((v.marketValue ?? Decimal.zero) > Decimal.zero) v,
    ];
    final own = priced.length <= AllocationView.maxAssetSlices
        ? priced
        : priced.take(AllocationView.maxAssetSlices - 1).toList();
    final rest = priced.skip(own.length);
    return [
      for (final (i, v) in own.indexed)
        (
          label: assetDisplayName(l10n, v.holding.asset),
          color: AppPalette.chart[i % AppPalette.chart.length],
          value: v.marketValue!,
        ),
      if (rest.isNotEmpty)
        (
          label: l10n.allocationOther,
          color: AppPalette.silver,
          value: rest.fold(Decimal.zero, (sum, v) => sum + v.marketValue!),
        ),
    ];
  }
}

/// Donut + legend for [slices] of [total].
class AllocationChart extends StatelessWidget {
  const AllocationChart({required this.slices, required this.total, super.key});

  final List<AllocationSlice> slices;
  final Decimal total;

  static final Decimal _hundred = Decimal.fromInt(100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Percent computed with Decimal; converted to double only for drawing.
    final percents = [
      for (final s in slices)
        total == Decimal.zero
            ? Decimal.zero
            : (s.value * _hundred / total).toDecimal(
                scaleOnInfinitePrecision: 4,
              ),
    ];

    final chart = DonutChart(
      size: 120,
      thickness: 16,
      semanticsLabel: [
        for (final (i, s) in slices.indexed)
          '${s.label} ${Formatters.percent(percents[i], decimals: 0)}',
      ].join(', '),
      segments: [
        for (final (i, s) in slices.indexed)
          DonutSegment(
            fraction: percents[i].toDouble() / 100,
            color: s.color,
          ),
      ],
    );
    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, s) in slices.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  s.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                Formatters.percent(percents[i], decimals: 1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: AppTypography.tabular,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      // Side by side; stacked when a large system font size leaves the
      // legend too little room.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final legendWidth = constraints.maxWidth - 120 - AppSpacing.xl;
          final needed = MediaQuery.textScalerOf(context).scale(170);
          if (legendWidth >= needed) {
            return Row(
              children: [
                chart,
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: legend),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: chart),
              const SizedBox(height: AppSpacing.xl),
              legend,
            ],
          );
        },
      ),
    );
  }
}
