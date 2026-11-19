import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/utils/app_logger.dart';
import 'package:vestra/features/market/data/datasources/kap_disclosure_local_data_source.dart';
import 'package:vestra/features/market/data/mappers/kap_disclosure_mapper.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';
import 'package:vestra/features/market/domain/repositories/disclosure_repository.dart';
import 'package:vestra/features/market/domain/services/disclosure_policy.dart';

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
  Stream<Result<List<KapDisclosure>>> watchAll() async* {
    try {
      await for (final rows in _local.watchAll()) {
        yield Success([for (final r in rows) r.toEntity()]);
      }
    } on Object catch (e, st) {
      AppLogger.error('kap watch failed', error: e, stackTrace: st);
      yield Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<DateTime?> lastFetchedAt(String symbol) => _local.fetchedAt(symbol);

  @override
  Future<Result<int>> refresh(String symbol) async {
    final code = symbol.toUpperCase();
    final result = await _provider.fetchDisclosures(
      code,
      limit: DisclosurePolicy.perStock,
    );
    switch (result) {
      case Err(:final failure):
        return Err(failure);
      case Success(value: final items):
        try {
          await _local.replaceForSymbol(code, [
            for (final d in items) d.toCompanion(),
          ], _clock());
          return Success(items.length);
        } on Object catch (e, st) {
          AppLogger.error('kap store failed', error: e, stackTrace: st);
          return Err(StorageFailure(e.toString()));
        }
    }
  }

  @override
  Future<Result<void>> keepOnly(Set<String> symbols) async {
    try {
      await _local.keepOnly({for (final s in symbols) s.toUpperCase()});
      return const Success(null);
    } on Object catch (e, st) {
      AppLogger.error('kap cleanup failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }
}
