import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/utils/formatters.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

/// How personal amounts are shown right now: in which currency and whether
/// they are masked (privacy mode). Market prices never go through this.
@immutable
class AmountFormat {
  const AmountFormat({
    this.currency = DisplayCurrency.tryLira,
    this.rateTry,
    this.hidden = false,
  });

  /// TRY only, visible.
  static const plain = AmountFormat();

  static const String mask = '•••••';

  /// Selected currency; [DisplayCurrency.tryLira] when no rate is known.
  final DisplayCurrency currency;

  /// TRY per one unit of [currency]; `null` for TRY.
  final Decimal? rateTry;
  final bool hidden;

  bool get converts => currency != DisplayCurrency.tryLira && rateTry != null;

  String get symbol => converts ? currency.symbol : '₺';

  /// A TRY amount in the selected currency (converted at [rateTry]).
  /// With [convert] `false` it stays in TRY (costs, transaction prices).
  String money(Decimal tryAmount, {bool convert = true}) {
    final s = convert ? symbol : '₺';
    if (hidden) return '$s$mask';
    return Formatters.money(_value(tryAmount, convert), symbol: s);
  }

  String signedMoney(Decimal tryAmount, {bool convert = true}) {
    final s = convert ? symbol : '₺';
    if (hidden) return '$s$mask';
    return Formatters.signedMoney(_value(tryAmount, convert), symbol: s);
  }

  /// Any other personal figure (e.g. "100 adet").
  String private(String text) => hidden ? mask : text;

  Decimal convertValue(Decimal tryAmount) => _value(tryAmount, true);

  Decimal _value(Decimal tryAmount, bool convert) {
    final rate = rateTry;
    if (!convert || !converts || rate == null || rate == Decimal.zero) {
      return tryAmount;
    }
    return (tryAmount / rate).toDecimal(scaleOnInfinitePrecision: 6);
  }

  @override
  bool operator ==(Object other) =>
      other is AmountFormat &&
      other.currency == currency &&
      other.rateTry == rateTry &&
      other.hidden == hidden;

  @override
  int get hashCode => Object.hash(currency, rateTry, hidden);
}

/// Provides the current [AmountFormat] to the widget tree.
class AmountDisplay extends InheritedWidget {
  const AmountDisplay({required this.format, required super.child, super.key});

  final AmountFormat format;

  /// [AmountFormat.plain] when there is no [AmountDisplay] above.
  static AmountFormat of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AmountDisplay>()?.format ??
      AmountFormat.plain;

  @override
  bool updateShouldNotify(AmountDisplay oldWidget) =>
      oldWidget.format != format;
}
