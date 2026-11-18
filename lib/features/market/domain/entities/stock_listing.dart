/// One BIST stock from the provider's full market list.
class StockListing {
  const StockListing({required this.symbol, required this.name});

  final String symbol;
  final String name;
}
