import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:vestra/core/database/converters.dart';
import 'package:vestra/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Assets, AssetTransactions, PriceCache, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Bump on every schema change, then run
  /// `dart run drift_dev make-migrations` and add a step in [migration].
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Future versions: replace with `stepByStep(...)` from the generated
    // `app_database.steps.dart`.
    onUpgrade: (m, from, to) async {},
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
