import 'package:flutter/material.dart';
import 'package:vestra/core/theme/app_colors.dart';
import 'package:vestra/core/theme/app_tokens.dart';

class ChoiceTile<T> {
  const ChoiceTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

/// Equal-width option tiles (icon above label). The selected tile gets an
/// accent tint and border; works for 2-4 short options.
class ChoiceTiles<T> extends StatelessWidget {
  const ChoiceTiles({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<ChoiceTile<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, option) in options.indexed) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _Tile(
              option: option,
              isSelected: option.value == selected,
              onTap: () => onChanged(option.value),
            ),
          ),
        ],
      ],
    );
  }
}

class _Tile<T> extends StatelessWidget {
  const _Tile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final ChoiceTile<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final muted = context.vestraColors.surfaceMuted;
    final fg = isSelected ? accent : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? accent.withValues(alpha: 0.12) : muted,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: isSelected ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md + AppSpacing.xxs,
              horizontal: AppSpacing.xs,
            ),
            child: Column(
              children: [
                Icon(option.icon, size: 22, color: fg),
                const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
