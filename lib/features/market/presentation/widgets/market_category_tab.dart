import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/l10n/failure_messages.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/empty_state.dart';
import 'package:vestra/features/market/domain/entities/market_calendar.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/services/refresh_policy.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/market/presentation/instrument_labels.dart';
import 'package:vestra/features/market/presentation/price_refresh_controller.dart';
import 'package:vestra/features/market/presentation/widgets/quote_tile.dart';

const String _settingsPath = '/settings';

/// One market tab: status (last/next update, session), notices and the
/// price list for a single [category].
class MarketCategoryTab extends ConsumerWidget {
  const MarketCategoryTab({required this.category, super.key});

  final QuoteCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final allQuotes = ref.watch(quotesProvider).value ?? const <Quote>[];
    final held = ref.watch(heldStockSymbolsProvider).value ?? const {};
    final refresh = ref.watch(priceRefreshControllerProvider);
    final hasKey = ref.watch(burkutKeyProvider).value != null;
    final calendar =
        ref.watch(marketCalendarProvider).value ?? MarketCalendar.empty;

    final quotes = _quotesFor(allQuotes, held);
    final isStocks = category == QuoteCategory.stocks;

    return RefreshIndicator(
      onRefresh: () => _onPullToRefresh(context, ref, quotes, calendar),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.md,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          if (isStocks) ...[
            _ExchangeSelector(labels: [l10n.marketExchangeBist]),
            const SizedBox(height: AppSpacing.lg),
          ],
          _StatusCard(
            category: category,
            quotes: quotes,
            isRefreshing: refresh.refreshing.contains(category),
            sessionOpen: RefreshPolicy.isSessionOpen(DateTime.now(), calendar),
          ),
          ?_notice(l10n, refresh, hasKey: hasKey),
          const SizedBox(height: AppSpacing.lg),
          if (quotes.isEmpty)
            AppCard(
              child: isStocks && held.isEmpty
                  ? EmptyState(
                      icon: Icons.candlestick_chart_outlined,
                      title: l10n.marketStocksEmptyTitle,
                      message: l10n.marketStocksEmptyMessage,
                    )
                  : EmptyState(
                      icon: Icons.candlestick_chart_outlined,
                      title: l10n.marketEmptyTitle,
                      message: l10n.marketEmptyMessage,
                    ),
            )
          else
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  for (final (i, quote) in quotes.indexed) ...[
                    if (i > 0)
                      const Divider(indent: 72, endIndent: AppSpacing.lg),
                    QuoteTile(quote: quote),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Pull-to-refresh follows the same rules as the automatic refresh; when
  /// nothing was fetched for this tab, say why.
  Future<void> _onPullToRefresh(
    BuildContext context,
    WidgetRef ref,
    List<Quote> quotes,
    MarketCalendar calendar,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final requested = await ref
        .read(priceRefreshControllerProvider.notifier)
        .refreshDue(manual: true);
    if (requested.contains(category)) return;

    final String message;
    if (category == QuoteCategory.stocks &&
        !RefreshPolicy.isSessionOpen(DateTime.now(), calendar)) {
      message = l10n.marketSessionClosed;
    } else {
      final next = RefreshPolicy.nextUpdate(_latest(quotes));
      if (next == null) return;
      message = l10n.marketUpToDate(DateFormatters.shortDateTime(next));
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<Quote> _quotesFor(List<Quote> all, Set<String> held) {
    return [
      for (final q in all)
        if (QuoteCategory.of(q.instrument.type) == category)
          if (category != QuoteCategory.stocks ||
              held.contains(q.instrument.code))
            q,
    ]..sort((a, b) {
      final byOrder = instrumentOrder(
        a.instrument,
      ).compareTo(instrumentOrder(b.instrument));
      if (byOrder != 0) return byOrder;
      final byType = a.instrument.type.index.compareTo(b.instrument.type.index);
      return byType != 0
          ? byType
          : a.instrument.code.compareTo(b.instrument.code);
    });
  }

  Widget? _notice(
    AppLocalizations l10n,
    PriceRefreshState refresh, {
    required bool hasKey,
  }) {
    // FX works without a key (free fallback), the others don't.
    if (!hasKey && category != QuoteCategory.fx) {
      return _NoticeCard(
        icon: Icons.key_outlined,
        title: l10n.marketNeedsKeyTitle,
        message: l10n.marketNeedsKeyMessage,
        actionLabel: l10n.marketGoToSettings,
      );
    }
    final failure = refresh.lastError ?? refresh.failures[category];
    if (failure == null) return null;
    if (failure is AuthFailure && failure.missingKey) return null;
    final isKeyIssue = failure is AuthFailure;
    return _NoticeCard(
      icon: isKeyIssue ? Icons.key_off_outlined : Icons.info_outline,
      message: failureMessage(l10n, failure),
      actionLabel: isKeyIssue ? l10n.marketGoToSettings : null,
    );
  }

  static DateTime? _latest(List<Quote> quotes) {
    DateTime? latest;
    for (final q in quotes) {
      if (latest == null || q.fetchedAt.isAfter(latest)) latest = q.fetchedAt;
    }
    return latest;
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.category,
    required this.quotes,
    required this.isRefreshing,
    required this.sessionOpen,
  });

  final QuoteCategory category;
  final List<Quote> quotes;
  final bool isRefreshing;
  final bool sessionOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final latest = MarketCategoryTab._latest(quotes);
    final next = RefreshPolicy.nextUpdate(latest);
    final isStocks = category == QuoteCategory.stocks;
    final usesFallback = quotes.any((q) => q.source == QuoteSource.frankfurter);

    final title = isRefreshing
        ? l10n.marketRefreshing
        : latest == null
        ? l10n.marketNotUpdatedYet
        : l10n.marketLastUpdated(DateFormatters.shortDateTime(latest));

    final details = <String>[
      if (isStocks && !sessionOpen)
        l10n.marketSessionClosed
      else if (!isRefreshing && next != null && next.isAfter(DateTime.now()))
        l10n.marketNextUpdate(DateFormatters.shortDateTime(next)),
      if (isStocks) l10n.marketStocksRule else l10n.marketUpdateRule,
      if (usesFallback)
        l10n.marketSourceFallback
      else if (quotes.isNotEmpty && isStocks)
        l10n.marketSourceBurkut,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: isRefreshing
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  details.join('\n'),
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
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
  });

  final IconData icon;
  final String? title;
  final String message;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
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
                  if (actionLabel != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 40),
                        ),
                        onPressed: () => context.go(_settingsPath),
                        child: Text(actionLabel!),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exchange chips inside the Borsa tab. Only BIST for now; more exchanges
/// (e.g. US) can be added as further chips later.
class _ExchangeSelector extends StatelessWidget {
  const _ExchangeSelector({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Row(
      children: [
        for (final (i, label) in labels.indexed) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppRadius.pillAll,
              border: Border.all(color: accent, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs + AppSpacing.xxs,
              ),
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(color: accent),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
