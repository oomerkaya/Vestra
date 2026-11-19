import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/l10n/failure_messages.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/collapsible_section.dart';
import 'package:vestra/core/widgets/empty_state.dart';
import 'package:vestra/core/widgets/messages.dart';
import 'package:vestra/features/market/domain/entities/market_calendar.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/services/refresh_policy.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/market/presentation/instrument_labels.dart';
import 'package:vestra/features/market/presentation/price_refresh_controller.dart';
import 'package:vestra/features/market/presentation/widgets/quote_tile.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';

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
    final heldInstruments = ref.watch(heldInstrumentsProvider);
    final refresh = ref.watch(priceRefreshControllerProvider);
    final hasKey = ref.watch(burkutKeyProvider).value != null;
    final calendar =
        ref.watch(marketCalendarProvider).value ?? MarketCalendar.empty;

    final quotes = _sorted([
      for (final q in allQuotes)
        if (QuoteCategory.of(q.instrument.type) == category) q,
    ]);
    final mine = [
      for (final q in quotes)
        if (heldInstruments.contains(q.instrument)) q,
    ];
    final isStocks = category == QuoteCategory.stocks;
    final isSearchable = isStocks || category == QuoteCategory.funds;

    return RefreshIndicator(
      onRefresh: () => _onPullToRefresh(context, ref, quotes, calendar),
      child: ListView(
        key: PageStorageKey('market-${category.name}'),
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
            calendar: calendar,
          ),
          ?_notice(l10n, refresh, hasKey: hasKey),
          const SizedBox(height: AppSpacing.lg),
          if (quotes.isEmpty && !isSearchable)
            AppCard(
              child: EmptyState(
                icon: Icons.candlestick_chart_outlined,
                title: l10n.marketEmptyTitle,
                message: l10n.marketEmptyMessage,
              ),
            )
          else ...[
            CollapsibleSection(
              title: l10n.marketSectionMine,
              trailing: mine.length.toString(),
              storageKey: 'market-${category.name}-mine',
              child: mine.isEmpty
                  ? _Hint(l10n.marketNoHoldingsInCategory)
                  : _QuoteList(quotes: mine),
            ),
            const SizedBox(height: AppSpacing.md),
            if (isSearchable)
              _SearchableAllSection(
                quotes: quotes,
                initiallyExpanded: mine.isEmpty,
                storageKey: 'market-${category.name}-all',
                hint: isStocks
                    ? l10n.marketSearchStocks
                    : l10n.marketSearchFunds,
                emptyText: isStocks
                    ? l10n.marketStocksNotLoaded
                    : l10n.marketFundsNotLoaded,
              )
            else
              CollapsibleSection(
                title: l10n.marketSectionAll,
                trailing: quotes.length.toString(),
                initiallyExpanded: mine.isEmpty,
                storageKey: 'market-${category.name}-all',
                child: _QuoteList(quotes: quotes),
              ),
          ],
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
      final next = RefreshPolicy.nextUpdate(
        _latest(quotes),
        category: category,
        calendar: calendar,
      );
      if (next == null) return;
      message = l10n.marketUpToDate(DateFormatters.shortDateTime(next));
    }
    messenger.showMessage(message);
  }

  static List<Quote> _sorted(List<Quote> quotes) => quotes
    ..sort((a, b) {
      final byOrder = instrumentOrder(
        a.instrument,
      ).compareTo(instrumentOrder(b.instrument));
      if (byOrder != 0) return byOrder;
      final byType = a.instrument.type.index.compareTo(b.instrument.type.index);
      return byType != 0
          ? byType
          : a.instrument.code.compareTo(b.instrument.code);
    });

  Widget? _notice(
    AppLocalizations l10n,
    PriceRefreshState refresh, {
    required bool hasKey,
  }) {
    // Every category needs the Bürküt key.
    if (!hasKey) {
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
    required this.calendar,
  });

  final QuoteCategory category;
  final List<Quote> quotes;
  final bool isRefreshing;
  final bool sessionOpen;
  final MarketCalendar calendar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final latest = MarketCategoryTab._latest(quotes);
    final next = RefreshPolicy.nextUpdate(
      latest,
      category: category,
      calendar: calendar,
    );
    final isStocks = category == QuoteCategory.stocks;

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
      // Funds have one price per day (NAV), so "delayed" does not apply.
      switch (category) {
        QuoteCategory.stocks => l10n.marketStocksRule,
        QuoteCategory.funds => l10n.marketFundsRule,
        _ => '${l10n.marketUpdateRule}. ${l10n.marketDataDelayed}.',
      },
      if (quotes.isNotEmpty && isStocks) l10n.marketDataDelayed,
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

class _QuoteList extends StatelessWidget {
  const _QuoteList({required this.quotes});

  final List<Quote> quotes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, quote) in quotes.indexed) ...[
          if (i > 0) const Divider(indent: 72, endIndent: AppSpacing.lg),
          QuoteTile(quote: quote),
        ],
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

/// Every stock or fund from the last snapshot, with search. Rendered in
/// pages of 50 so hundreds/thousands of rows don't build at once.
class _SearchableAllSection extends StatefulWidget {
  const _SearchableAllSection({
    required this.quotes,
    required this.initiallyExpanded,
    required this.storageKey,
    required this.hint,
    required this.emptyText,
  });

  final List<Quote> quotes;
  final bool initiallyExpanded;
  final String storageKey;
  final String hint;
  final String emptyText;

  @override
  State<_SearchableAllSection> createState() => _SearchableAllSectionState();
}

class _SearchableAllSectionState extends State<_SearchableAllSection> {
  static const int _pageSize = 50;

  String _query = '';
  int _visible = _pageSize;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matches = _query.isEmpty
        ? widget.quotes
        : [
            for (final q in widget.quotes)
              if (q.instrument.code.startsWith(_query) ||
                  turkishUpperCase(q.name ?? '').contains(_query))
                q,
          ];
    final shown = matches.take(_visible).toList();
    final remaining = matches.length - shown.length;

    return CollapsibleSection(
      title: l10n.marketSectionAll,
      trailing: widget.quotes.length.toString(),
      initiallyExpanded: widget.initiallyExpanded,
      storageKey: widget.storageKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: TextField(
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
              ),
              onChanged: (v) => setState(() {
                _query = turkishUpperCase(v.trim());
                _visible = _pageSize;
              }),
            ),
          ),
          if (widget.quotes.isEmpty)
            _Hint(widget.emptyText)
          else if (matches.isEmpty)
            _Hint(l10n.pickerNoResults)
          else
            _QuoteList(quotes: shown),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: TextButton(
                onPressed: () => setState(() => _visible += _pageSize),
                child: Text(
                  l10n.marketShowMore(
                    (remaining < _pageSize ? remaining : _pageSize).toString(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
