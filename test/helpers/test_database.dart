import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:vestra/core/database/app_database.dart';

/// Fresh in-memory database per call.
AppDatabase createTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
