import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/widgets/collapsible_section.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/services/disclosure_policy.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/market/presentation/widgets/kap_disclosure_tile.dart';
import 'package:vestra/features/portfolio/presentation/kap_refresh_controller.dart';

/// Portfolio screen: the last 7 days' disclosures of the held stocks.
class PortfolioKapSection extends ConsumerStatefulWidget {
  const PortfolioKapSection({required this.symbols, super.key});

  /// Held stock symbols.
  final Set<String> symbols;

  @override
  ConsumerState<PortfolioKapSection> createState() =>
      _PortfolioKapSectionState();
}

class _PortfolioKapSectionState extends ConsumerState<PortfolioKapSection> {
  static const int _collapsedCount = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all = ref.watch(kapDisclosuresProvider).value ?? const [];
    final loading = ref.watch(kapRefreshControllerProvider).isNotEmpty;
    final held = [
      for (final d in all)
        if (widget.symbols.contains(d.symbol)) d,
    ];
    final since = DateTime.now().subtract(DisclosurePolicy.recentWindow);
    final recent = [
      for (final d in held)
        if (d.publishedAt.isAfter(since)) d,
    ];
    final visible = _showAll ? recent : recent.take(_collapsedCount).toList();

    return CollapsibleSection(
      title: l10n.kapSectionTitle,
      storageKey: 'portfolio-kap',
      trailing: recent.isEmpty ? null : '${recent.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (recent.isEmpty)
            KapMessage(
              loading
                  ? l10n.kapLoading
                  : held.isEmpty
                  ? l10n.kapNotLoaded
                  : l10n.kapNoneRecent,
            )
          else
            _DisclosureList(visible),
          if (recent.length > _collapsedCount)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _showAll = !_showAll),
                child: Text(
                  _showAll
                      ? l10n.kapShowLess
                      : l10n.kapShowAll('${recent.length}'),
                ),
              ),
            ),
          KapFooter(l10n.kapPortfolioFooter),
        ],
      ),
    );
  }
}

/// Asset detail screen: the latest disclosures of one stock. Fetches them
/// when the screen opens, if they are due (also for stocks outside the
/// automatic top 5).
class AssetKapSection extends ConsumerStatefulWidget {
  const AssetKapSection({required this.symbol, super.key});

  final String symbol;

  @override
  ConsumerState<AssetKapSection> createState() => _AssetKapSectionState();
}

class _AssetKapSectionState extends ConsumerState<AssetKapSection> {
  @override
  void initState() {
    super.initState();
    if (ref.read(autoRefreshEnabledProvider)) {
      unawaited(
        Future<void>.microtask(
          () => ref
              .read(kapRefreshControllerProvider.notifier)
              .ensureFresh(widget.symbol),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final symbol = widget.symbol.toUpperCase();
    final all = ref.watch(kapDisclosuresProvider).value ?? const [];
    final loading = ref.watch(kapRefreshControllerProvider).contains(symbol);
    final mine = [
      for (final d in all)
        if (d.symbol == symbol) d,
    ].take(DisclosurePolicy.perStock).toList();

    return CollapsibleSection(
      title: l10n.kapAssetSectionTitle,
      storageKey: 'asset-kap',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mine.isEmpty)
            KapMessage(loading ? l10n.kapLoading : l10n.kapNone)
          else
            _DisclosureList(mine, showSymbol: false),
          KapFooter(l10n.kapAssetFooter),
        ],
      ),
    );
  }
}

class _DisclosureList extends StatelessWidget {
  const _DisclosureList(this.items, {this.showSymbol = true});

  final List<KapDisclosure> items;
  final bool showSymbol;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, d) in items.indexed) ...[
        if (i > 0) const Divider(),
        KapDisclosureTile(disclosure: d, showSymbol: showSymbol),
      ],
    ],
  );
}
