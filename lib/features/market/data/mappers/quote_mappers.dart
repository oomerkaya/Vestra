import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/domain/instrument.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:drift/drift.dart';

extension QuoteToRow on Quote {
  PriceCacheCompanion toCompanion() => PriceCacheCompanion.insert(
    type: instrument.type.name,
    code: instrument.code,
    priceTry: priceTry,
    source: source.name,
    fetchedAt: fetchedAt,
    name: Value(name),
    changePercent: Value(changePercent),
    asOf: Value(asOf),
  );
}

extension PriceCacheRowToQuote on PriceCacheRow {
  /// `null` for rows with an unknown type/source (e.g. written by a newer
  /// app version); those are skipped instead of crashing.
  Quote? toEntity() {
    final assetType = AssetType.values.asNameMap()[type];
    final quoteSource = QuoteSource.values.asNameMap()[source];
    if (assetType == null || quoteSource == null) return null;
    return Quote(
      instrument: (type: assetType, code: code),
      priceTry: priceTry,
      source: quoteSource,
      fetchedAt: fetchedAt,
      name: name,
      changePercent: changePercent,
      asOf: asOf,
    );
  }
}
