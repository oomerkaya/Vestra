import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/data/datasources/stock_listing_local_data_source.dart';
import 'package:vestra/features/market/data/repositories/stock_directory_repository_impl.dart';
import 'package:vestra/features/market/domain/entities/stock_listing.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';

import '../../../helpers/test_database.dart';

class _Provider extends Mock implements StockListingProvider {}

void main() {
  late AppDatabase db;
  late _Provider provider;
  late DateTime now;
  late StockDirectoryRepositoryImpl repo;

  const thyao = StockListing(symbol: 'THYAO', name: 'TURK HAVA YOLLARI A.O.');
  const asels = StockListing(symbol: 'ASELS', name: 'ASELSAN');

  setUp(() {
    db = createTestDatabase();
    provider = _Provider();
    now = DateTime(2026, 11, 18, 12);
    repo = StockDirectoryRepositoryImpl(
      provider: provider,
      local: StockListingLocalDataSource(db),
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  test('first call fetches, sorts and caches', () async {
    when(
      () => provider.fetchListings(),
    ).thenAnswer((_) async => const Success([thyao, asels]));

    final list = (await repo.listings()).valueOrNull!;

    expect(list.map((s) => s.symbol), ['ASELS', 'THYAO']);
    verify(() => provider.fetchListings()).called(1);
  });

  test('fresh cache: no request for a week', () async {
    when(
      () => provider.fetchListings(),
    ).thenAnswer((_) async => const Success([thyao]));
    await repo.listings();

    now = now.add(const Duration(days: 6));
    await repo.listings();

    verify(() => provider.fetchListings()).called(1);
  });

  test('stale cache is refreshed after 7 days', () async {
    when(
      () => provider.fetchListings(),
    ).thenAnswer((_) async => const Success([thyao]));
    await repo.listings();

    now = now.add(const Duration(days: 7));
    await repo.listings();

    verify(() => provider.fetchListings()).called(2);
  });

  test('refresh failure falls back to the stale cache', () async {
    when(
      () => provider.fetchListings(),
    ).thenAnswer((_) async => const Success([thyao]));
    await repo.listings();
    now = now.add(const Duration(days: 30));
    when(
      () => provider.fetchListings(),
    ).thenAnswer((_) async => const Err(AuthFailure(missingKey: true)));

    final list = (await repo.listings()).valueOrNull!;

    expect(list.single.symbol, 'THYAO');
  });

  test('no cache and no key: failure', () async {
    when(
      () => provider.fetchListings(),
    ).thenAnswer((_) async => const Err(AuthFailure(missingKey: true)));

    final result = await repo.listings();

    expect((result as Err).failure, isA<AuthFailure>());
  });
}
