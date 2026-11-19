import 'package:flutter/material.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/theme/app_colors.dart';
import 'package:vestra/core/theme/app_tokens.dart';

/// Rounded square with a type-colored tint and a short label (e.g. `USD`).
class InstrumentAvatar extends StatelessWidget {
  const InstrumentAvatar({required this.type, required this.label, super.key});

  final AssetType type;
  final String label;

  static Color colorFor(AssetType type) => switch (type) {
    AssetType.currency => AppPalette.currency,
    AssetType.gold => AppPalette.gold,
    AssetType.silver => AppPalette.silver,
    AssetType.stock => AppPalette.stock,
    AssetType.fund => AppPalette.fund,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(type);
    final text = label.length > 4 ? label.substring(0, 4) : label;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        text,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
