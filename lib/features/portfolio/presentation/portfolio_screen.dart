import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/widgets/empty_state.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPortfolio)),
      body: EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.portfolioEmptyTitle,
        message: l10n.portfolioEmptyMessage,
      ),
    );
  }
}
