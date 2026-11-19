import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/utils/formatters.dart';
import 'package:flutter/material.dart';

/// Small label above a group of cards, with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(turkishUpperCase(title), style: style)),
          ?trailing,
        ],
      ),
    );
  }
}
