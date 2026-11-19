import 'package:drift/drift.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/features/market/data/dto/kap_disclosure_dto.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';

extension KapDisclosureDtoMapper on KapDisclosureDto {
  /// One entity per company: a disclosure naming "GARAN, TGB" is shown
  /// under both. The id is made unique per company.
  List<KapDisclosure> toEntities() => [
    for (final symbol in symbols)
      KapDisclosure(
        id: '$id:$symbol',
        symbol: symbol,
        title: title,
        summary: summary,
        url: url,
        publishedAt: publishedAt,
      ),
  ];
}

extension KapDisclosureRowMapper on KapDisclosureRow {
  KapDisclosure toEntity() => KapDisclosure(
    id: id,
    symbol: symbol,
    title: title,
    summary: summary,
    url: url,
    publishedAt: publishedAt,
  );
}

extension KapDisclosureEntityMapper on KapDisclosure {
  KapDisclosuresCompanion toCompanion() => KapDisclosuresCompanion.insert(
    id: id,
    symbol: symbol,
    title: title,
    summary: Value(summary),
    url: Value(url),
    publishedAt: publishedAt,
  );
}
