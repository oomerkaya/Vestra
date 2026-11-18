import 'dart:convert';

import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/features/market/domain/entities/stock_listing.dart';

/// Caches the BIST stock list as JSON in `app_settings` (~25 KB). Public
/// market metadata only; no prices.
class StockListingLocalDataSource {
  const StockListingLocalDataSource(this._db);

  static const String key = 'bist_listings';

  final AppDatabase _db;

  Future<({DateTime fetchedAt, List<StockListing> items})?> read() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    try {
      final json = jsonDecode(row.value) as Map<String, dynamic>;
      return (
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        items: [
          for (final item in json['items'] as List<dynamic>)
            StockListing(
              symbol: (item as Map<String, dynamic>)['s'] as String,
              name: item['n'] as String,
            ),
        ],
      );
    } on Object {
      return null;
    }
  }

  Future<void> write(DateTime fetchedAt, List<StockListing> items) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: key,
          value: jsonEncode({
            'fetchedAt': fetchedAt.toUtc().toIso8601String(),
            'items': [
              for (final i in items) {'s': i.symbol, 'n': i.name},
            ],
          }),
        ),
      );
}
