import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Stores [Decimal] as its exact string form so no precision is lost.
/// SQL arithmetic on these columns is intentionally not supported; all money
/// math happens in Dart.
class DecimalConverter extends TypeConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => value.toString();
}
