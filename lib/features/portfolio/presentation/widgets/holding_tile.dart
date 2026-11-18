import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/theme/app_typography.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/change_chip.dart';
import 'package:vestra/core/widgets/instrument_avatar.dart';
import 'package:vestra/features/market/presentation/instrument_labels.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:vestra/features/portfolio/presentation/portfolio_labels.dart';
import 'package:vestra/features/portfolio/presentation/widgets/portfolio_summary_card.dart';

/// One holding: avatar, name, quantity · avg cost, value and P/L.
class HoldingTile extends StatelessWidget {
  const HoldingTile({required this.valued, this.onTap, super.key});

  final ValuedHolding valued;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final h = valued.holding;
    final asset = h.asset;
    final avg = h.averageCostTry;
    final quantity = formatQuantity(l10n, asset, h.quantity);
    final subtitle = avg == null
        ? quantity
        : l10n.holdingQuantityAvg(quantity, Formatters.currencyTry(avg));
    final value = valued.marketValue;
    final pnl = valued.unrealizedPnl;
    final pnlPct = valued.unrealizedPnlPercent;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            InstrumentAvatar(
              type: asset.type,
              label: instrumentShortLabel((type: asset.type, code: asset.code)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assetDisplayName(l10n, asset),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value == null
                      ? l10n.portfolioNoPrice
                      : Formatters.currencyTry(value),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: AppTypography.tabular,
                    color: value == null
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                if (pnl != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ChangeChip(
                    label: pnlPct == null
                        ? Formatters.signedCurrencyTry(pnl)
                        : Formatters.percent(pnlPct, signed: true),
                    direction: directionOf(pnl),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
