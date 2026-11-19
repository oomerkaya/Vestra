import 'dart:async';

import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/router/app_routes.dart';
import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/widgets/app_card.dart';
import 'package:capira/core/widgets/collapsible_section.dart';
import 'package:capira/core/widgets/empty_state.dart';
import 'package:capira/core/widgets/error_state.dart';
import 'package:capira/core/widgets/section_header.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:capira/features/portfolio/presentation/widgets/allocation_card.dart';
import 'package:capira/features/portfolio/presentation/widgets/holding_tile.dart';
import 'package:capira/features/portfolio/presentation/widgets/period_summary_section.dart';
import 'package:capira/features/portfolio/presentation/widgets/portfolio_summary_card.dart';
import 'package:capira/features/portfolio/presentation/widgets/value_history_section.dart';
import 'package:capira/features/settings/presentation/display_preferences.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(portfolioSummaryProvider);
    if (summaryAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navPortfolio)),
        body: const Center(child: ErrorState()),
      );
    }
    final summary = summaryAsync.value ?? PortfolioSummary.empty;
    final hasStocks = ref.watch(heldStockSymbolsProvider).isNotEmpty;
    final hidden = ref.watch(privacyModeProvider);
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
          IconButton(
            tooltip: hidden ? l10n.privacyShow : l10n.privacyHide,
            onPressed: () =>
                unawaited(ref.read(privacyModeProvider.notifier).toggle()),
            icon: Icon(
              hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          if (hasStocks)
            IconButton(
              tooltip: l10n.kapIconTooltip,
              onPressed: () => context.push(AppRoutes.kap),
              icon: Badge.count(
                count: unseen,
                isLabelVisible: unseen > 0,
                // Accent, not red: red means a loss in this app.
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
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
          PortfolioSummaryCard(
            summary: summary,
            pricesAsOf: pricesAsOf,
            currencies: ref.watch(availableDisplayCurrenciesProvider),
            onCurrencyChanged: (c) =>
                unawaited(ref.read(displayCurrencyProvider.notifier).select(c)),
          ),
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
          // Analysis below the holdings: summary, history, allocation.
          if (summary.totalValue > Decimal.zero) ...[
            const SizedBox(height: AppSpacing.xl),
            const PeriodSummarySection(),
            const SizedBox(height: AppSpacing.lg),
            const ValueHistorySection(),
            const SizedBox(height: AppSpacing.lg),
            CollapsibleSection(
              title: l10n.portfolioAllocation,
              storageKey: 'portfolio-allocation',
              // Closed by default; the user opens it when needed.
              initiallyExpanded: false,
              child: AllocationView(summary: summary),
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
