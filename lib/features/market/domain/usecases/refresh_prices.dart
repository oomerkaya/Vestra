import 'package:decimal/decimal.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/repositories/market_repository.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:vestra/features/portfolio/domain/services/holding_calculator.dart';

/// Refreshes FX, metals and the stocks currently held (quantity > 0).
/// Stocks not in the portfolio are never requested.
class RefreshPrices {
  const RefreshPrices(this._market, this._portfolio);

  final MarketRepository _market;
  final PortfolioRepository _portfolio;

  Future<Result<RefreshReport>> call() async {
    final symbols = <String>{};
    final portfolio = await _portfolio.watchPortfolio().first;
    if (portfolio case Success(:final value)) {
      for (final item in value) {
        if (item.asset.type != AssetType.stock) continue;
        final holding = HoldingCalculator.calculate(
          item.asset,
          item.transactions,
        );
        if (holding.quantity > Decimal.zero) symbols.add(item.asset.code);
      }
    }
    return _market.refresh(stockSymbols: symbols);
  }
}
