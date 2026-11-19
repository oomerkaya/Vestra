import 'package:capira/core/database/app_database.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single app-wide database. Tests override this with an in-memory DB.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'capira'));
  ref.onDispose(db.close);
  return db;
});
