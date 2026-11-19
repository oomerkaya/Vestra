import 'package:capira/core/database/app_database.steps.dart';
import 'package:capira/core/database/converters.dart';
import 'package:capira/core/database/tables.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Assets,
    AssetTransactions,
    PriceCache,
    AppSettings,
    KapDisclosures,
    PortfolioSnapshots,
    AssetSnapshots,
    Goals,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Bump on every schema change, then run
  /// `dart run drift_dev make-migrations` and add a step in [migration].
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.priceCache, schema.priceCache.name);
        await m.addColumn(schema.priceCache, schema.priceCache.changePercent);
        await m.addColumn(schema.priceCache, schema.priceCache.asOf);
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.kapDisclosures);
      },
      from3To4: (m, schema) async {
        await m.createTable(schema.portfolioSnapshots);
        await m.createTable(schema.assetSnapshots);
        await m.createTable(schema.goals);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
