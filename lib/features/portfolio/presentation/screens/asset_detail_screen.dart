import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/l10n/failure_messages.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/router/app_routes.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/theme/app_typography.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/change_chip.dart';
import 'package:vestra/core/widgets/confirm_dialog.dart';
import 'package:vestra/core/widgets/empty_state.dart';
import 'package:vestra/core/widgets/instrument_avatar.dart';
import 'package:vestra/core/widgets/messages.dart';
import 'package:vestra/core/widgets/section_header.dart';
import 'package:vestra/features/market/presentation/instrument_labels.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';
import 'package:vestra/features/portfolio/domain/entities/holding.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/portfolio/presentation/portfolio_labels.dart';
import 'package:vestra/features/portfolio/presentation/widgets/kap_sections.dart';
import 'package:vestra/features/portfolio/presentation/widgets/portfolio_summary_card.dart';

/// One asset: position summary, buy/sell shortcuts and its transactions.
class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({required this.assetId, super.key});

  final int assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final holdings = ref.watch(holdingsProvider).value;
    final holding = holdings?.where((h) => h.asset.id == assetId).firstOrNull;
    final summary = ref.watch(portfolioSummaryProvider).value;
    final valued = summary?.holdings
        .where((v) => v.holding.asset.id == assetId)
        .firstOrNull;
    final transactions =
        ref.watch(assetTransactionsProvider(assetId)).value ??
        const <AssetTransaction>[];

    if (holding == null) {
      return Scaffold(
        appBar: AppBar(),
        body: holdings == null
            ? const Center(child: CircularProgressIndicator())
            : EmptyState(
                icon: Icons.search_off_rounded,
                title: l10n.assetNotFound,
                message: '',
              ),
      );
    }
    final asset = holding.asset;
    final instrument = (type: asset.type, code: asset.code);

    return Scaffold(
      appBar: AppBar(
        title: Text(assetDisplayName(l10n, asset)),
        actions: [
          IconButton(
            tooltip: l10n.assetDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => unawaited(_deleteAsset(context, ref, holding)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          _PositionCard(holding: holding, valued: valued),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.addTransactionFor(instrument),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.assetDetailBuy),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: holding.isClosed
                      ? null
                      : () => context.push(
                          AppRoutes.addTransactionFor(
                            instrument,
                            kind: TransactionKind.sell,
                          ),
                        ),
                  icon: const Icon(Icons.remove_rounded),
                  label: Text(l10n.assetDetailSell),
                ),
              ),
            ],
          ),
          if (asset.type == AssetType.stock) ...[
            const SizedBox(height: AppSpacing.lg),
            AssetKapSection(symbol: asset.code),
          ],
          SectionHeader(l10n.assetDetailTransactions),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (final (i, tx) in transactions.indexed) ...[
                  if (i > 0)
                    const Divider(
                      indent: AppSpacing.lg,
                      endIndent: AppSpacing.lg,
                    ),
                  _TransactionTile(
                    holding: holding,
                    transaction: tx,
                    onTap: () => context.push(
                      AppRoutes.editTransaction(assetId, tx.id),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAsset(
    BuildContext context,
    WidgetRef ref,
    Holding holding,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: l10n.assetDeleteConfirmTitle,
      message: l10n.assetDeleteConfirmMessage(
        assetDisplayName(l10n, holding.asset),
      ),
    );
    if (!confirmed) return;
    final result = await ref.read(deleteAssetProvider).call(holding.asset.id);
    switch (result) {
      case Success():
        router.pop();
        messenger.showMessage(l10n.assetDeleted);
      case Err(:final failure):
        messenger.showMessage(failureMessage(l10n, failure));
    }
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.holding, this.valued});

  final Holding holding;
  final ValuedHolding? valued;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final asset = holding.asset;
    final value = valued?.marketValue;
    final pnl = valued?.unrealizedPnl;
    final pnlPct = valued?.unrealizedPnlPercent;
    final avg = holding.averageCostTry;
    final realized = holding.realizedPnlTry;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InstrumentAvatar(
                type: asset.type,
                label: instrumentShortLabel((
                  type: asset.type,
                  code: asset.code,
                )),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  assetSubtitle(l10n, asset),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.assetDetailValue, style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value == null
                ? l10n.portfolioNoPrice
                : Formatters.currencyTry(value),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFeatures: AppTypography.tabular,
            ),
          ),
          if (pnl != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ChangeChip(
              label: pnlPct == null
                  ? Formatters.signedCurrencyTry(pnl)
                  : '${Formatters.signedCurrencyTry(pnl)} '
                        '(${Formatters.percent(pnlPct, signed: true)})',
              direction: directionOf(pnl),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          _Row(
            label: l10n.assetDetailQuantity,
            value: formatQuantity(l10n, asset, holding.quantity),
          ),
          _Row(
            label: l10n.assetDetailAvgCost,
            value: avg == null
                ? l10n.portfolioCostUnknown
                : Formatters.currencyTry(avg),
          ),
          if (realized != null && realized != Decimal.zero)
            _Row(
              label: l10n.assetDetailRealized,
              value: Formatters.signedCurrencyTry(realized),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: AppTypography.tabular,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.holding,
    required this.transaction,
    required this.onTap,
  });

  final Holding holding;
  final AssetTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tx = transaction;
    final isBuy = tx.kind == TransactionKind.buy;
    final price = tx.unitPriceTry;
    final quantity = formatQuantity(l10n, holding.asset, tx.quantity);
    final total = price == null ? null : tx.quantity * price;
    final d = tx.date.toLocal();
    final date =
        '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.${d.year}';

    return ListTile(
      onTap: onTap,
      leading: Icon(
        isBuy ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        '${isBuy ? l10n.txKindBuy : l10n.txKindSell} · $date',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        price == null
            ? quantity
            : l10n.txLine(quantity, Formatters.currencyTry(price)),
      ),
      trailing: total == null
          ? null
          : Text(
              Formatters.currencyTry(total),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: AppTypography.tabular,
              ),
            ),
    );
  }
}
