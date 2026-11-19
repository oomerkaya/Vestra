import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/router/app_routes.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/collapsible_section.dart';
import 'package:vestra/core/widgets/empty_state.dart';
import 'package:vestra/core/widgets/section_header.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/portfolio/presentation/widgets/allocation_card.dart';
import 'package:vestra/features/portfolio/presentation/widgets/holding_tile.dart';
import 'package:vestra/features/portfolio/presentation/widgets/kap_sections.dart';
import 'package:vestra/features/portfolio/presentation/widgets/portfolio_summary_card.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary =
        ref.watch(portfolioSummaryProvider).value ?? PortfolioSummary.empty;
    final stockSymbols = {
      for (final v in summary.holdings)
        if (v.holding.asset.type == AssetType.stock) v.holding.asset.code,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPortfolio)),
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
          PortfolioSummaryCard(summary: summary),
          if (summary.totalValue > Decimal.zero) ...[
            const SizedBox(height: AppSpacing.lg),
            CollapsibleSection(
              title: l10n.portfolioAllocation,
              storageKey: 'portfolio-allocation',
              child: AllocationChart(
                valueByCategory: summary.valueByCategory,
                total: summary.totalValue,
              ),
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
          if (stockSymbols.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            PortfolioKapSection(symbols: stockSymbols),
          ],
        ],
      ),
    );
  }
}
