import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/empty_state.dart';
import 'package:vestra/features/market/presentation/widgets/kap_disclosure_tile.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/portfolio/presentation/kap_refresh_controller.dart';
import 'package:vestra/features/portfolio/presentation/widgets/kap_sections.dart';

/// All stored KAP disclosures of held stocks (last 30 days), newest first,
/// with a filter per stock. Opening it clears the badge on the portfolio
/// screen.
class KapScreen extends ConsumerStatefulWidget {
  const KapScreen({super.key});

  @override
  ConsumerState<KapScreen> createState() => _KapScreenState();
}

class _KapScreenState extends ConsumerState<KapScreen> {
  /// `null` = all stocks.
  String? _symbol;

  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.microtask(
        () => ref.read(kapRefreshControllerProvider.notifier).markSeen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all = ref.watch(heldDisclosuresProvider);
    final busy = ref.watch(kapRefreshControllerProvider).isBusy;
    final symbols = {for (final d in all) d.symbol}.toList()..sort();
    final selected = symbols.contains(_symbol) ? _symbol : null;
    final shown = [
      for (final d in all)
        if (selected == null || d.symbol == selected) d,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kapScreenTitle),
        bottom: busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(AppSpacing.xxs),
                child: LinearProgressIndicator(minHeight: AppSpacing.xxs),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          if (symbols.length > 1) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: Text(l10n.kapFilterAll),
                  selected: selected == null,
                  onSelected: (_) => setState(() => _symbol = null),
                ),
                for (final s in symbols)
                  ChoiceChip(
                    label: Text(s),
                    selected: selected == s,
                    onSelected: (_) => setState(() => _symbol = s),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (shown.isEmpty)
                  EmptyState(
                    icon: Icons.campaign_outlined,
                    title: l10n.kapEmptyTitle,
                    message: l10n.kapEmptyMessage,
                  )
                else
                  KapDisclosureList(shown),
              ],
            ),
          ),
          KapFooter(l10n.kapScreenFooter),
        ],
      ),
    );
  }
}
