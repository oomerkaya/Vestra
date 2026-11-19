import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/router/app_routes.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/collapsible_section.dart';
import 'package:vestra/core/widgets/empty_state.dart';
import 'package:vestra/core/widgets/section_header.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/portfolio/presentation/widgets/allocation_card.dart';
import 'package:vestra/features/portfolio/presentation/widgets/holding_tile.dart';
import 'package:vestra/features/portfolio/presentation/widgets/portfolio_summary_card.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary =
        ref.watch(portfolioSummaryProvider).value ?? PortfolioSummary.empty;
    final hasStocks = ref.watch(heldStockSymbolsProvider).isNotEmpty;
    final unseen = ref.watch(kapUnseenCountProvider);
    final withNews = ref.watch(newDisclosureSymbolsProvider);
    final key = ref.watch(burkutKeyProvider);
    final missingKey = key.hasValue && (key.value ?? '').isEmpty;
    final pricesAsOf = summary.holdings
        .map((v) => v.quote?.fetchedAt)
        .nonNulls
        .fold<DateTime?>(
          null,
          (latest, t) => latest == null || t.isAfter(latest) ? t : latest,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navPortfolio),
        actions: [
          if (hasStocks)
            IconButton(
              tooltip: l10n.kapIconTooltip,
              onPressed: () => context.push(AppRoutes.kap),
              icon: Badge.count(
                count: unseen,
                isLabelVisible: unseen > 0,
                child: const Icon(Icons.campaign_outlined),
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addTransaction),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.portfolioAddAsset),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxxl + AppSpacing.xxl,
        ),
        children: [
          if (missingKey) ...[
            const _MissingKeyCard(),
            const SizedBox(height: AppSpacing.lg),
          ],
          PortfolioSummaryCard(summary: summary, pricesAsOf: pricesAsOf),
          if (summary.totalValue > Decimal.zero) ...[
            const SizedBox(height: AppSpacing.lg),
            CollapsibleSection(
              title: l10n.portfolioAllocation,
              storageKey: 'portfolio-allocation',
              // Closed by default; the user opens it when needed.
              initiallyExpanded: false,
              child: AllocationView(summary: summary),
            ),
          ],
          SectionHeader(l10n.portfolioHoldings),
          if (summary.isEmpty)
            AppCard(
              child: EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.portfolioEmptyTitle,
                message: l10n.portfolioEmptyMessage,
              ),
            )
          else ...[
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  for (final (i, valued) in summary.holdings.indexed) ...[
                    if (i > 0)
                      const Divider(indent: 72, endIndent: AppSpacing.lg),
                    HoldingTile(
                      valued: valued,
                      hasNewDisclosure: withNews.contains(
                        valued.holding.asset.code,
                      ),
                      onTap: () => context.push(
                        AppRoutes.assetDetail(valued.holding.asset.id),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (summary.missingPriceCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.xs,
                  0,
                ),
                child: Text(
                  l10n.portfolioMissingPrices(
                    summary.missingPriceCount.toString(),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Shown while no Bürküt key is saved: without it no prices arrive.
class _MissingKeyCard extends StatelessWidget {
  const _MissingKeyCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.key_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.portfolioKeyTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.portfolioKeyMessage,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => context.go(AppRoutes.settings),
                  child: Text(l10n.portfolioKeyAction),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
