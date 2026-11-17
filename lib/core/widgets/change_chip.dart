import 'package:flutter/material.dart';
import 'package:vestra/core/theme/app_colors.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/theme/app_typography.dart';

enum ChangeDirection { up, down, flat }

/// Pill showing a gain/loss, e.g. `▲ +₺3.120 (%1,27)`.
/// Green/red is reserved for this widget; don't use it for anything else.
class ChangeChip extends StatelessWidget {
  const ChangeChip({
    required this.label,
    required this.direction,
    super.key,
  });

  final String label;
  final ChangeDirection direction;

  @override
  Widget build(BuildContext context) {
    final colors = context.vestraColors;
    final (fg, bg, icon) = switch (direction) {
      ChangeDirection.up => (
        colors.gain,
        colors.gainContainer,
        Icons.arrow_upward_rounded,
      ),
      ChangeDirection.down => (
        colors.loss,
        colors.lossContainer,
        Icons.arrow_downward_rounded,
      ),
      ChangeDirection.flat => (
        colors.textSecondary,
        colors.surfaceMuted,
        Icons.remove_rounded,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pillAll),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xxs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                fontFeatures: AppTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
