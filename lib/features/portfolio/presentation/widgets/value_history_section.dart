import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/utils/formatters.dart';
import 'package:capira/core/widgets/amount_display.dart';
import 'package:capira/core/widgets/change_chip.dart';
import 'package:capira/core/widgets/collapsible_section.dart';
import 'package:capira/core/widgets/line_chart.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_snapshot.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:capira/features/portfolio/presentation/widgets/portfolio_summary_card.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HistoryRange {
  week(7),
  month(30),
  quarter(90),
  year(365),
  all(null);

  const HistoryRange(this.days);

  final int? days;
}

/// Portfolio value per day, from the values recorded on the device.
class ValueHistorySection extends ConsumerStatefulWidget {
  const ValueHistorySection({super.key});

  @override
  ConsumerState<ValueHistorySection> createState() =>
      _ValueHistorySectionState();
}

class _ValueHistorySectionState extends ConsumerState<ValueHistorySection> {
  HistoryRange _range = HistoryRange.month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final format = AmountDisplay.of(context);
    final all = ref.watch(snapshotsProvider).value ?? const [];
    final shown = _inRange(all, _range);
    final values = [for (final s in shown) _inCurrency(s, format)];

    return CollapsibleSection(
      title: l10n.historyTitle,
      storageKey: 'portfolio-history',
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final r in HistoryRange.values)
                  ChoiceChip(
                    label: Text(_label(l10n, r)),
                    selected: r == _range,
                    onSelected: (_) => setState(() => _range = r),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (values.length < 2)
              Text(l10n.historyEmpty, style: theme.textTheme.bodyMedium)
            else ...[
              _ChangeLine(
                first: values.first,
                last: values.last,
                from: shown.first.date,
                to: shown.last.date,
              ),
              const SizedBox(height: AppSpacing.md),
              LineChart(
                values: [for (final v in values) v.toDouble()],
                semanticsLabel: l10n.historyChartLabel(
                  DateFormatters.date(shown.first.date),
                  DateFormatters.date(shown.last.date),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(l10n.historyNote, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  static List<PortfolioSnapshot> _inRange(
    List<PortfolioSnapshot> all,
    HistoryRange range,
  ) {
    final days = range.days;
    if (days == null || all.isEmpty) return all;
    final from = all.last.date.subtract(Duration(days: days));
    return [
      for (final s in all)
        if (!s.date.isBefore(from)) s,
    ];
  }

  /// The day's value in the selected currency, at that day's rate when it
  /// was stored (else today's).
  static Decimal _inCurrency(PortfolioSnapshot s, AmountFormat format) {
    if (!format.converts) return s.valueTry;
    final rate =
        switch (format.currency) {
          DisplayCurrency.usd => s.usdTry,
          DisplayCurrency.eur => s.eurTry,
          DisplayCurrency.tryLira => null,
        } ??
        format.rateTry;
    if (rate == null || rate == Decimal.zero) return s.valueTry;
    return (s.valueTry / rate).toDecimal(scaleOnInfinitePrecision: 6);
  }

  static String _label(AppLocalizations l10n, HistoryRange r) => switch (r) {
    HistoryRange.week => l10n.historyRangeWeek,
    HistoryRange.month => l10n.historyRangeMonth,
    HistoryRange.quarter => l10n.historyRangeQuarter,
    HistoryRange.year => l10n.historyRangeYear,
    HistoryRange.all => l10n.historyRangeAll,
  };
}

/// "+$120,00 (+%3,10) · 12.11.2026 – 19.11.2026" in the shown currency.
class _ChangeLine extends StatelessWidget {
  const _ChangeLine({
    required this.first,
    required this.last,
    required this.from,
    required this.to,
  });

  /// Already converted to the display currency.
  final Decimal first;
  final Decimal last;
  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context) {
    final format = AmountDisplay.of(context);
    final change = last - first;
    final percent = first == Decimal.zero
        ? null
        : (change * Decimal.fromInt(100) / first).toDecimal(
            scaleOnInfinitePrecision: 4,
          );
    final amount = format.hidden
        ? '${format.symbol}${AmountFormat.mask}'
        : Formatters.signedMoney(change, symbol: format.symbol);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChangeChip(
          label: percent == null
              ? amount
              : '$amount (${Formatters.percent(percent, signed: true)})',
          direction: directionOf(change),
        ),
        Text(
          '${DateFormatters.date(from)} – ${DateFormatters.date(to)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
