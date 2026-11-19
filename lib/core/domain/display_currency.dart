/// Currency the portfolio totals are shown in. Costs are always kept in TRY;
/// USD and EUR are conversions at the current rate.
enum DisplayCurrency {
  tryLira('₺', null),
  usd(r'$', 'USD'),
  eur('€', 'EUR');

  const DisplayCurrency(this.symbol, this.currencyCode);

  final String symbol;

  /// Code of the currency quote used for the conversion; `null` for TRY.
  final String? currencyCode;
}
