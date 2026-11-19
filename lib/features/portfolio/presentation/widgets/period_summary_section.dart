import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/utils/formatters.dart';
import 'package:capira/core/widgets/amount_display.dart';
import 'package:capira/core/widgets/change_chip.dart';
import 'package:capira/core/widgets/collapsible_section.dart';
import 'package:capira/features/market/presentation/instrument_labels.dart';
import 'package:capira/features/portfolio/domain/services/period_summary_calculator.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:capira/features/portfolio/presentation/widgets/portfolio_summary_card.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Last 7 / 30 days: value change, how much of it came from buying or
/// selling and how much from prices, best and worst performer.
class PeriodSummarySection extends ConsumerStatefulWidget {
  const PeriodSummarySection({super.key});

  @override
  ConsumerState<PeriodSummarySection> createState() =>
      _PeriodSummarySectionState();
}

class _PeriodSummarySectionState extends ConsumerState<PeriodSummarySection> {
  SummaryPeriod _period = SummaryPeriod.week;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final summary = ref.watch(periodSummaryProvider(_period)).value;

    return CollapsibleSection(
      title: l10n.summaryTitle,
      storageKey: 'portfolio-summary',
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<SummaryPeriod>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: SummaryPeriod.week,
                  label: Text(l10n.summaryWeek),
                ),
                ButtonSegment(
                  value: SummaryPeriod.month,
                  label: Text(l10n.summaryMonth),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.single),
            ),
            const SizedBox(height: AppSpacing.md),
            if (summary == null)
              Text(l10n.summaryEmpty, style: theme.textTheme.bodyMedium)
            else
              _SummaryBody(summary: summary, period: _period),
          ],
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.summary, required this.period});

  final PeriodSummary summary;
  final SummaryPeriod period;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final format = AmountDisplay.of(context);
    final effectPct = summary.marketEffectPercent;
    final requestedStart = DateTime.now().subtract(
      Duration(days: period.days + 1),
    );
    final best = summary.best;
    final worst = summary.worst;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Line(
          label: l10n.summaryMarketEffect,
          trailing: ChangeChip(
            label: effectPct == null
                ? format.signedMoney(summary.marketEffect)
                : '${format.signedMoney(summary.marketEffect)} '
                      '(${Formatters.percent(effectPct, signed: true)})',
            direction: directionOf(summary.marketEffect),
          ),
        ),
        _Line(
          label: l10n.summaryChange,
          value: format.signedMoney(summary.change),
        ),
        if (summary.netInvested != Decimal.zero)
          _Line(
            label: l10n.summaryNetInvested,
            value: format.signedMoney(summary.netInvested),
          ),
        if (best != null)
          _Line(
            label: l10n.summaryBest,
            value:
                '${instrumentShortName(l10n, best.instrument)} '
                '${Formatters.percent(best.changePercent, signed: true)}',
          ),
        if (worst != null)
          _Line(
            label: l10n.summaryWorst,
            value:
                '${instrumentShortName(l10n, worst.instrument)} '
                '${Formatters.percent(worst.changePercent, signed: true)}',
          ),
        if (summary.since.isAfter(requestedStart))
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              l10n.summarySince(DateFormatters.date(summary.since)),
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, this.value, this.trailing});

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.md),
          // The figure gets all the remaining room, right-aligned.
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  trailing ??
                  Text(
                    value ?? '',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
