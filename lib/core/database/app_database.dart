import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:vestra/core/database/app_database.steps.dart';
import 'package:vestra/core/database/converters.dart';
import 'package:vestra/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Assets, AssetTransactions, PriceCache, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Bump on every schema change, then run
  /// `dart run drift_dev make-migrations` and add a step in [migration].
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.priceCache, schema.priceCache.name);
        await m.addColumn(schema.priceCache, schema.priceCache.changePercent);
        await m.addColumn(schema.priceCache, schema.priceCache.asOf);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
