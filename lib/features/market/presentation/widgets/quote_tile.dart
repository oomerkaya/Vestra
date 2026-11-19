import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/theme/app_typography.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/change_chip.dart';
import 'package:vestra/core/widgets/instrument_avatar.dart';
import 'package:vestra/core/widgets/trailing_figures.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/presentation/instrument_labels.dart';

/// One price row: avatar, name + code, price and daily change.
class QuoteTile extends StatelessWidget {
  const QuoteTile({required this.quote, super.key});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final change = quote.changePercent;
    final decimals = priceDecimals(quote.priceTry);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          InstrumentAvatar(
            type: quote.instrument.type,
            label: instrumentShortLabel(quote.instrument),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instrumentName(
                    l10n,
                    quote.instrument,
                    providerName: quote.name,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  // Stocks: company name from the market snapshot.
                  (quote.instrument.type == AssetType.stock ||
                              quote.instrument.type == AssetType.fund) &&
                          quote.name != null
                      ? quote.name!
                      : instrumentSubtitle(l10n, quote.instrument),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TrailingFigures(
            children: [
              Text(
                Formatters.currencyTry(quote.priceTry, decimals: decimals),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: AppTypography.tabular,
                ),
              ),
              if (change != null) ...[
                const SizedBox(height: AppSpacing.xs),
                ChangeChip(
                  label: Formatters.percent(change.abs()),
                  direction: change > Decimal.zero
                      ? ChangeDirection.up
                      : change < Decimal.zero
                      ? ChangeDirection.down
                      : ChangeDirection.flat,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
