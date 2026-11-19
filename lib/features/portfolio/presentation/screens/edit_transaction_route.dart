import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/widgets/empty_state.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:capira/features/portfolio/presentation/screens/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads the asset and transaction for `/portfolio/asset/:id/transaction/:tx`
/// and opens the form in edit mode.
class EditTransactionRoute extends ConsumerWidget {
  const EditTransactionRoute({
    required this.assetId,
    required this.transactionId,
    super.key,
  });

  final int assetId;
  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(holdingsProvider).value;
    final transactions = ref.watch(assetTransactionsProvider(assetId)).value;
    if (holdings == null || transactions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final asset = holdings
        .where((h) => h.asset.id == assetId)
        .firstOrNull
        ?.asset;
    final tx = transactions.where((t) => t.id == transactionId).firstOrNull;
    if (asset == null || tx == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: context.l10n.assetNotFound,
          message: '',
        ),
      );
    }
    return TransactionFormScreen.edit(asset: asset, transaction: tx);
  }
}
