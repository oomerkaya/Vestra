import 'package:capira/core/error/result.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:capira/features/portfolio/domain/repositories/snapshot_repository.dart';
import 'package:capira/features/portfolio/domain/services/snapshot_builder.dart';

/// Stores today's portfolio value (overwriting today's earlier value).
/// Does nothing while no holding has a price.
class RecordSnapshot {
  const RecordSnapshot(this._repository);

  final SnapshotRepository _repository;

  Future<Result<void>> call({
    required PortfolioSummary summary,
    required List<Quote> quotes,
    required DateTime now,
  }) async {
    final built = SnapshotBuilder.build(
      summary: summary,
      quotes: quotes,
      now: now,
    );
    if (built == null) return const Success(null);
    return _repository.record(built.$1, built.$2);
  }
}
