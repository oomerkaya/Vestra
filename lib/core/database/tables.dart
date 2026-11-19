import 'package:capira/core/database/converters.dart';
import 'package:drift/drift.dart';

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

/// Last known price per instrument. Survives restarts so the app works
/// offline with the most recent values.
@DataClassName('PriceCacheRow')
class PriceCache extends Table {
  TextColumn get type => text()();
  TextColumn get code => text()();
  TextColumn get priceTry => text().map(const DecimalConverter())();
  TextColumn get source => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  /// Display name from the provider (v2).
  TextColumn get name => text().nullable()();

  /// Daily change in percent, e.g. `1.27` (v2).
  TextColumn get changePercent =>
      text().map(const DecimalConverter()).nullable()();

  /// Provider's own timestamp of the price, if given (v2).
  DateTimeColumn get asOf => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {type, code};
}

/// Recent KAP disclosures of tracked stocks (v3). Replaced per symbol on
/// every fetch, so only the latest few per stock are kept.
@DataClassName('KapDisclosureRow')
class KapDisclosures extends Table {
  /// Bürküt's id of the disclosure.
  TextColumn get id => text()();
  TextColumn get symbol => text()();
  TextColumn get title => text()();
  TextColumn get summary => text().nullable()();

  /// Link to the original disclosure on kap.org.tr, if given.
  TextColumn get url => text().nullable()();
  DateTimeColumn get publishedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Portfolio total once per Istanbul day (v4), for the value history and
/// the weekly/monthly summary. The row of the current day is overwritten
/// until the day ends, so it holds the day's last known value.
@DataClassName('PortfolioSnapshotRow')
class PortfolioSnapshots extends Table {
  /// `YYYY-MM-DD` in Istanbul time.
  TextColumn get day => text()();
  TextColumn get valueTry => text().map(const DecimalConverter())();

  /// Cost of the priced holdings whose cost is known.
  TextColumn get costTry => text().map(const DecimalConverter()).nullable()();

  /// TRY per USD / EUR that day, to draw the history in those currencies.
  TextColumn get usdTry => text().map(const DecimalConverter()).nullable()();
  TextColumn get eurTry => text().map(const DecimalConverter()).nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {day};
}

/// Each held instrument's quantity and price per day (v4), for the best and
/// worst performers in the summary.
@DataClassName('AssetSnapshotRow')
class AssetSnapshots extends Table {
  TextColumn get day => text()();
  TextColumn get type => text()();
  TextColumn get code => text()();
  TextColumn get quantity => text().map(const DecimalConverter())();
  TextColumn get priceTry => text().map(const DecimalConverter())();

  @override
  Set<Column> get primaryKey => {day, type, code};
}

/// Savings goals (v4).
@DataClassName('GoalRow')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();

  /// portfolioValue | assetQuantity
  TextColumn get kind => text()();
  TextColumn get target => text().map(const DecimalConverter())();

  /// Value goals: tryLira | usd | eur.
  TextColumn get currency => text().nullable()();

  /// Quantity goals: the instrument.
  TextColumn get assetType => text().nullable()();
  TextColumn get assetCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Simple key/value store for app preferences (non-secret only).
@DataClassName('SettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
