import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/widgets/collapsible_section.dart';
import 'package:capira/features/market/domain/entities/kap_disclosure.dart';
import 'package:capira/features/market/presentation/widgets/kap_disclosure_tile.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asset detail screen of a held stock: its disclosures of the last 30
/// days from storage. Never sends a request.
class AssetKapSection extends ConsumerWidget {
  const AssetKapSection({required this.symbol, super.key});

  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final code = symbol.toUpperCase();
    final mine = [
      for (final d
          in ref.watch(heldDisclosuresProvider).value ??
              const <KapDisclosure>[])
        if (d.symbol == code) d,
    ];

    return CollapsibleSection(
      title: l10n.kapAssetSectionTitle,
      storageKey: 'asset-kap',
      trailing: mine.isEmpty ? null : '${mine.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mine.isEmpty)
            KapMessage(l10n.kapNone)
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
