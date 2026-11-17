import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/portfolio/domain/entities/holding.dart';
import 'package:vestra/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:vestra/features/portfolio/domain/services/holding_calculator.dart';

/// Live list of holdings. Closed positions (quantity 0) are included so the
/// UI can decide whether to show them.
class WatchHoldings {
  const WatchHoldings(this._repository);

  final PortfolioRepository _repository;

  Stream<Result<List<Holding>>> call() => _repository.watchPortfolio().map(
    (result) => result.map(
      (items) => [
        for (final item in items)
          HoldingCalculator.calculate(item.asset, item.transactions),
      ],
    ),
  );
}
