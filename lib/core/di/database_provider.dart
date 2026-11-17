import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/database/app_database.dart';

/// Single app-wide database. Tests override this with an in-memory DB.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'vestra'));
  ref.onDispose(db.close);
  return db;
});
