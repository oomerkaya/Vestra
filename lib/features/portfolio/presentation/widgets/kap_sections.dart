import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/widgets/collapsible_section.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/services/disclosure_policy.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/market/presentation/widgets/kap_disclosure_tile.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/portfolio/presentation/kap_refresh_controller.dart';

/// Asset detail screen of a held stock: its latest disclosures. Once half
/// of the monthly quota is used, opening the screen fetches this stock if
/// nothing updated it today.
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
    final loading = ref
        .watch(kapRefreshControllerProvider)
        .loading
        .contains(symbol);
    final mine = [
      for (final d in ref.watch(heldDisclosuresProvider))
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
            KapDisclosureList(mine, showSymbol: false),
          KapFooter(l10n.kapAssetFooter),
        ],
      ),
    );
  }
}

/// Disclosure tiles separated by dividers.
class KapDisclosureList extends StatelessWidget {
  const KapDisclosureList(this.items, {this.showSymbol = true, super.key});

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
