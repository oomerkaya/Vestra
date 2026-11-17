import 'package:drift/drift.dart';
import 'package:vestra/core/database/converters.dart';

/// Enum-like columns are plain TEXT here; feature mappers own the mapping so
/// that `core` does not depend on feature domain types.

@DataClassName('AssetRow')
class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// currency | gold | silver | stock
  TextColumn get type => text()();

  /// e.g. USD, GRAM, CEYREK, SILVER_GRAM, THYAO
  TextColumn get code => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {type, code},
  ];
}

@DataClassName('TransactionRow')
class AssetTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId =>
      integer().references(Assets, #id, onDelete: KeyAction.cascade)();

  /// buy | sell
  TextColumn get kind => text()();
  TextColumn get quantity => text().map(const DecimalConverter())();

  /// Price per unit in TRY. Null when the user does not know the cost.
  TextColumn get unitPriceTry =>
      text().map(const DecimalConverter()).nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Last known price per instrument (filled in Phase 3).
@DataClassName('PriceCacheRow')
class PriceCache extends Table {
  TextColumn get type => text()();
  TextColumn get code => text()();
  TextColumn get priceTry => text().map(const DecimalConverter())();
  TextColumn get source => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {type, code};
}

/// Simple key/value store for app preferences (non-secret only).
@DataClassName('SettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
