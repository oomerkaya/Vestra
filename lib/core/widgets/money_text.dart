import 'package:capira/core/theme/app_typography.dart';
import 'package:capira/core/widgets/amount_display.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// A personal TRY amount with tabular digits, shown in the selected
/// currency and masked in privacy mode ([AmountDisplay]). The fractional
/// part is rendered smaller and dimmer when [emphasizeInteger] is set.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.value, {
    this.style,
    this.emphasizeInteger = false,
    super.key,
  });

  final Decimal value;
  final TextStyle? style;
  final bool emphasizeInteger;

  @override
  Widget build(BuildContext context) {
    final base = (style ?? DefaultTextStyle.of(context).style).copyWith(
      fontFeatures: AppTypography.tabular,
    );
    final text = AmountDisplay.of(context).money(value);
    final comma = text.lastIndexOf(',');
    if (!emphasizeInteger || comma < 0) return Text(text, style: base);

    final fraction = base.copyWith(
      fontSize: (base.fontSize ?? 14) * 0.6,
      color: base.color?.withValues(alpha: 0.55),
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, comma), style: base),
          TextSpan(text: text.substring(comma), style: fraction),
        ],
      ),
      semanticsLabel: text,
    );
  }
}
