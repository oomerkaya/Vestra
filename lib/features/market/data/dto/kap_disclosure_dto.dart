import 'package:vestra/features/market/data/dto/json_parsing.dart';

/// One item from `/kap?symbol=X`. Verified against the live API on
/// 2026-11-19 (`test/fixtures/burkut/kap.json`, THYAO):
/// `{"data": {"content": [{id, symbol, title, summary, short_description,
/// publishDate}], "totalElements", ...}}`. `summary` is often empty; the
/// link to the original disclosure is inside `short_description`
/// ("Orjinal Link: https://www.kap.org.tr/tr/Bildirim/1695191\n...").
class KapDisclosureDto {
  const KapDisclosureDto({
    required this.id,
    required this.symbol,
    required this.title,
    required this.publishedAt,
    this.summary,
    this.url,
  });

  /// `null` when id, symbol, title or date is missing.
  static KapDisclosureDto? fromJson(Map<String, dynamic> json) {
    final id = _text(json['id']);
    final symbol = _text(json['symbol'])?.toUpperCase();
    final title = _text(json['title']);
    final publishedAt = parseDateTime(json['publishDate'] ?? json['date']);
    if (id == null || symbol == null || title == null || publishedAt == null) {
      return null;
    }
    return KapDisclosureDto(
      id: id,
      symbol: symbol,
      title: title,
      summary: _text(json['summary']),
      url:
          _link(json['url']) ??
          _link(json['link']) ??
          _link(json['short_description']),
      publishedAt: publishedAt,
    );
  }

  final String id;
  final String symbol;
  final String title;
  final String? summary;
  final String? url;
  final DateTime publishedAt;

  /// Only https links to KAP itself are kept, so the app never opens an
  /// unexpected site.
  static final RegExp _kapLink = RegExp(
    r'https://(?:www\.)?kap\.org\.tr/[^\s"<>]+',
  );

  static String? _link(Object? value) =>
      value == null ? null : _kapLink.firstMatch(value.toString())?.group(0);

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  /// Accepts the paged `{"data": {"content": [...]}}` envelope, as well as
  /// `{"data": [...]}` or a bare list.
  static List<KapDisclosureDto> listFrom(Object? payload) {
    final data = payload is Map<String, dynamic> ? payload['data'] : null;
    final paged = data is Map<String, dynamic> ? data['content'] : null;
    return [
      for (final json in unwrapList(paged ?? payload))
        ?KapDisclosureDto.fromJson(json),
    ];
  }
}

/// A `/kap` response with the quota headers.
class BurkutKapResponse {
  const BurkutKapResponse(this.items, {this.quotaRemaining, this.quotaLimit});

  final List<KapDisclosureDto> items;
  final int? quotaRemaining;
  final int? quotaLimit;
}
