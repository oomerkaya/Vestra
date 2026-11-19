import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/theme/app_colors.dart';
import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/presentation/widgets/market_category_tab.dart';
import 'package:flutter/material.dart';

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
            preferredSize: const Size.fromHeight(66),
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
                  l10n.marketTabFunds,
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
            MarketCategoryTab(category: QuoteCategory.funds),
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
    final colors = context.capiraColors;
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
          labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          tabs: [
            // Four tabs on a phone: shrink the label rather than cut it.
            for (final label in labels)
              Tab(
                // 48 dp touch target with the padding around it.
                height: 46,
                child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
              ),
          ],
        ),
      ),
    );
  }
}
