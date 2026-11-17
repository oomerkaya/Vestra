import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/empty_state.dart';
import 'package:vestra/core/widgets/money_text.dart';
import 'package:vestra/core/widgets/section_header.dart';

/// Placeholder until Phase 4 wires holdings and prices in.
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPortfolio)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          _TotalCard(label: l10n.portfolioTotalValue, total: Decimal.zero),
          SectionHeader(l10n.portfolioHoldings),
          AppCard(
            child: EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.portfolioEmptyTitle,
              message: l10n.portfolioEmptyMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.label, required this.total});

  final String label;
  final Decimal total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          MoneyText(total, style: text.displaySmall, emphasizeInteger: true),
        ],
      ),
    );
  }
}
