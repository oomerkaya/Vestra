import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/empty_state.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMarket)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          AppCard(
            child: EmptyState(
              icon: Icons.candlestick_chart_outlined,
              title: l10n.marketEmptyTitle,
              message: l10n.marketEmptyMessage,
            ),
          ),
        ],
      ),
    );
  }
}
