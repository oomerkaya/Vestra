import 'package:capira/core/database/converters.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

void main() {
  group('DecimalConverter', () {
    const converter = DecimalConverter();

    for (final value in ['0', '1', '-2.5', '0.000000001', '123456789.987']) {
      test('round-trips $value', () {
        final decimal = d(value);
        expect(converter.fromSql(converter.toSql(decimal)), decimal);
      });
    }
  });

  test('database opens with foreign keys enabled', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();

    expect(row.data.values.single, 1);
    expect(db.schemaVersion, 4);
  });
}
