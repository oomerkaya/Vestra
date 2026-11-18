import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_colors.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/presentation/widgets/market_category_tab.dart';

/// Market prices in three tabs: currencies, metals, stocks. Each tab has
/// its own "last updated" time and refresh rules (see `RefreshPolicy`).
class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: QuoteCategory.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navMarket),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.sm,
              ),
              child: _SegmentedTabBar(
                labels: [
                  l10n.marketTabFx,
                  l10n.marketTabMetals,
                  l10n.marketTabStocks,
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            MarketCategoryTab(category: QuoteCategory.fx),
            MarketCategoryTab(category: QuoteCategory.metals),
            MarketCategoryTab(category: QuoteCategory.stocks),
          ],
        ),
      ),
    );
  }
}

/// Pill-style tab selector in the design system's muted surface.
class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.vestraColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: TabBar(
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: AppRadius.smAll,
          ),
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          labelStyle: theme.textTheme.labelLarge,
          unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          splashBorderRadius: AppRadius.smAll,
          tabs: [
            for (final label in labels) Tab(height: 36, text: label),
          ],
        ),
      ),
    );
  }
}
