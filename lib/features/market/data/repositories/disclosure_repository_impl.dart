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
  Future<DateTime?> lastFetchedAt(String symbol) =>
      _local.fetchedAt(symbol.toUpperCase());

  @override
  Future<DateTime?> lastFeedAt() => _local.feedAt();

  @override
  Future<Result<int>> refresh(String symbol) async {
    final code = symbol.toUpperCase();
    final result = await _provider.fetchDisclosures(
      code,
      limit: DisclosurePolicy.perStock,
    );
    return switch (result) {
      Err(:final failure) => Err(failure),
      Success(value: final items) => _store(
        items,
        stampKey: '${KapDisclosureLocalDataSource.fetchedAtPrefix}$code',
      ),
    };
  }

  @override
  Future<Result<int>> refreshFeed(Set<String> held) async {
    final wanted = {for (final s in held) s.toUpperCase()};
    final lastFeedAt = await _local.feedAt();
    final found = <KapDisclosure>[];
    var page = 0;
    while (true) {
      final result = await _provider.fetchDisclosureFeed(page: page);
      if (result case Err(:final failure)) {
        // Keep what earlier pages delivered, but do not mark the feed as
        // read, so the next attempt reaches back far enough again.
        if (found.isNotEmpty) await _store(found, stampKey: null);
        return Err(failure);
      }
      final feed = result.valueOrNull!;
      found.addAll(feed.items.where((d) => wanted.contains(d.symbol)));
      page++;
      if (!DisclosurePolicy.needsOlderPage(
        pagesRead: page,
        oldestOnPage: feed.oldest,
        isLast: feed.isLast,
        lastFeedAt: lastFeedAt,
      )) {
        break;
      }
    }
    return _store(found, stampKey: KapDisclosureLocalDataSource.feedAtKey);
  }

  Future<Result<int>> _store(
    List<KapDisclosure> items, {
    required String? stampKey,
  }) async {
    try {
      await _local.upsertAll(
        [for (final d in items) d.toCompanion()],
        stampKey: stampKey,
        at: _clock(),
      );
      return Success(items.length);
    } on Object catch (e, st) {
      AppLogger.error('kap store failed', error: e, stackTrace: st);
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> keepOnly(Set<String> symbols) async {
    try {
      await _local.keepOnly({
        for (final s in symbols) s.toUpperCase(),
      }, before: _clock().subtract(DisclosurePolicy.keepFor));
      return const Success(null);
    } on Object catch (e, st) {
      AppLogger.error('kap cleanup failed', error: e, stackTrace: st);
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
