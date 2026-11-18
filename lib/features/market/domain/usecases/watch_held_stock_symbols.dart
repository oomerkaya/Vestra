import 'package:decimal/decimal.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:vestra/features/portfolio/domain/services/holding_calculator.dart';

/// Stock codes currently held (quantity > 0). Only these are ever
/// requested from the price provider or shown on the stocks tab.
class WatchHeldStockSymbols {
  const WatchHeldStockSymbols(this._portfolio);

  final PortfolioRepository _portfolio;

  Stream<Set<String>> call() => _portfolio.watchPortfolio().map(
    (result) => switch (result) {
      Err() => const <String>{},
      Success(:final value) => {
        for (final item in value)
          if (item.asset.type == AssetType.stock &&
              HoldingCalculator.calculate(
                    item.asset,
                    item.transactions,
                  ).quantity >
                  Decimal.zero)
            item.asset.code,
      },
    },
  );
}
