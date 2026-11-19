import 'package:capira/core/error/result.dart';
import 'package:capira/features/portfolio/domain/repositories/portfolio_repository.dart';

/// Removes an asset together with all of its transactions.
class DeleteAsset {
  const DeleteAsset(this._repository);

  final PortfolioRepository _repository;

  Future<Result<void>> call(int assetId) => _repository.deleteAsset(assetId);
}
