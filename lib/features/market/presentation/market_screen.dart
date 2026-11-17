import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/l10n/failure_messages.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/empty_state.dart';
import 'package:vestra/core/widgets/section_header.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/market/presentation/instrument_labels.dart';
import 'package:vestra/features/market/presentation/price_refresh_controller.dart';
import 'package:vestra/features/market/presentation/widgets/quote_tile.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  static const String settingsPath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final quotes = ref.watch(quotesProvider).value ?? const <Quote>[];
    final refresh = ref.watch(priceRefreshControllerProvider);
    final hasKey = ref.watch(burkutKeyProvider).value != null;

    final grouped = _group(quotes);
    final notice = _notice(l10n, refresh, hasKey: hasKey);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMarket)),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(priceRefreshControllerProvider.notifier)
            .refresh(manual: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            0,
            AppSpacing.screen,
            AppSpacing.xxl,
          ),
          children: [
            _StatusLine(quotes: quotes, isRefreshing: refresh.isRefreshing),
            if (notice != null) ...[
              const SizedBox(height: AppSpacing.md),
              notice,
            ],
            if (quotes.isEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: EmptyState(
                  icon: Icons.candlestick_chart_outlined,
                  title: l10n.marketEmptyTitle,
                  message: l10n.marketEmptyMessage,
                ),
              ),
            ],
            for (final (title, items) in [
              (l10n.marketSectionFx, grouped[AssetType.currency]),
              (
                l10n.marketSectionMetals,
                [...?grouped[AssetType.gold], ...?grouped[AssetType.silver]],
              ),
              (l10n.marketSectionStocks, grouped[AssetType.stock]),
            ])
              if (items != null && items.isNotEmpty) ...[
                SectionHeader(title),
                _QuoteGroup(quotes: items),
              ],
          ],
        ),
      ),
    );
  }

  Widget? _notice(
    AppLocalizations l10n,
    PriceRefreshState refresh, {
    required bool hasKey,
  }) {
    if (!hasKey) {
      return _NoticeCard(
        icon: Icons.key_outlined,
        title: l10n.marketNeedsKeyTitle,
        message: l10n.marketNeedsKeyMessage,
        actionLabel: l10n.marketGoToSettings,
        actionPath: settingsPath,
      );
    }
    final failures = refresh.lastReport?.failures.values ?? const <Failure>[];
    final failure = refresh.lastError ?? failures.firstOrNull;
    if (failure == null) return null;
    final isKeyIssue = failure is AuthFailure;
    return _NoticeCard(
      icon: isKeyIssue ? Icons.key_off_outlined : Icons.info_outline,
      message: failureMessage(l10n, failure),
      actionLabel: isKeyIssue ? l10n.marketGoToSettings : null,
      actionPath: isKeyIssue ? settingsPath : null,
    );
  }

  static Map<AssetType, List<Quote>> _group(List<Quote> quotes) {
    final map = <AssetType, List<Quote>>{};
    for (final q in quotes) {
      (map[q.instrument.type] ??= []).add(q);
    }
    for (final list in map.values) {
      list.sort((a, b) {
        final byOrder = instrumentOrder(
          a.instrument,
        ).compareTo(instrumentOrder(b.instrument));
        return byOrder != 0
            ? byOrder
            : a.instrument.code.compareTo(b.instrument.code);
      });
    }
    return map;
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.quotes, required this.isRefreshing});

  final List<Quote> quotes;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.bodySmall;
    DateTime? latest;
    var usesFallback = false;
    for (final q in quotes) {
      if (latest == null || q.fetchedAt.isAfter(latest)) latest = q.fetchedAt;
      if (q.source == QuoteSource.frankfurter) usesFallback = true;
    }
    final lines = <String>[
      if (isRefreshing)
        l10n.marketRefreshing
      else if (latest != null)
        l10n.marketLastUpdated(DateFormatters.shortDateTime(latest)),
      if (quotes.any((q) => q.source == QuoteSource.burkut))
        l10n.marketSourceBurkut,
      if (usesFallback) l10n.marketSourceFallback,
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(lines.join('\n'), style: style?.copyWith(height: 1.5)),
    );
  }
}

class _QuoteGroup extends StatelessWidget {
  const _QuoteGroup({required this.quotes});

  final List<Quote> quotes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (final (i, quote) in quotes.indexed) ...[
            if (i > 0) const Divider(indent: 72, endIndent: AppSpacing.lg),
            QuoteTile(quote: quote),
          ],
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.message,
    this.title,
    this.actionLabel,
    this.actionPath,
  });

  final IconData icon;
  final String? title;
  final String message;
  final String? actionLabel;
  final String? actionPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final path = actionPath;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                ),
                if (actionLabel != null && path != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () => context.go(path),
                      child: Text(actionLabel!),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
