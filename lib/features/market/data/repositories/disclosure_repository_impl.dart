import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/core/utils/app_logger.dart';
import 'package:capira/features/market/data/datasources/kap_disclosure_local_data_source.dart';
import 'package:capira/features/market/data/mappers/kap_disclosure_mapper.dart';
import 'package:capira/features/market/domain/entities/kap_disclosure.dart';
import 'package:capira/features/market/domain/providers/price_providers.dart';
import 'package:capira/features/market/domain/repositories/disclosure_repository.dart';
import 'package:capira/features/market/domain/services/disclosure_policy.dart';

class DisclosureRepositoryImpl implements DisclosureRepository {
  DisclosureRepositoryImpl({
    required this._provider,
    required this._local,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DisclosureProvider _provider;
  final KapDisclosureLocalDataSource _local;
  final DateTime Function() _clock;

  @override
  Stream<Result<List<KapDisclosure>>> watchForSymbols(
    Set<String> symbols,
  ) async* {
    try {
      final codes = {for (final s in symbols) s.toUpperCase()};
      await for (final rows in _local.watchForSymbols(codes)) {
        yield Success([for (final r in rows) r.toEntity()]);
      }
    } on Object catch (e, st) {
      AppLogger.error('kap watch failed', error: e, stackTrace: st);
      yield Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<DateTime?> lastFeedAt() => _local.feedAt();

  @override
  Future<Result<int>> refreshFeed() async {
    final result = await _provider.fetchDisclosureFeed();
    switch (result) {
      case Err(:final failure):
        return Err(failure);
      case Success(value: final items):
        try {
          await _local.storeFeed([
            for (final d in items) d.toCompanion(),
          ], at: _clock());
          return Success(items.length);
        } on Object catch (e, st) {
          AppLogger.error('kap store failed', error: e, stackTrace: st);
          return Err(StorageFailure(e.toString()));
        }
    }
  }

  @override
  Future<Result<void>> prune() async {
    try {
      await _local.prune(before: _clock().subtract(DisclosurePolicy.keepFor));
      return const Success(null);
    } on Object catch (e, st) {
      AppLogger.error('kap prune failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Stream<DateTime?> watchSeenAt() => _local.watchSeenAt();

  @override
  Future<Result<void>> markSeen(DateTime at) async {
    try {
      await _local.setSeenAt(at);
      return const Success(null);
    } on Object catch (e, st) {
      AppLogger.error('kap seen failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }
}
