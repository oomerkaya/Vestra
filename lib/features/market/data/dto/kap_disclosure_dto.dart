import 'package:vestra/features/market/data/dto/json_parsing.dart';

/// One item from `/kap`. Verified against the live API on 2026-11-19
/// (`test/fixtures/burkut/kap_feed.json`):
/// - Envelope: `{"data": {"content": [...], "totalElements", "last", ...}}`.
/// - Item: `id`, `symbol`, `title`, `summary` (often empty),
///   `short_description` (contains the link to the original disclosure:
///   "Orjinal Link: https://www.kap.org.tr/tr/Bildirim/1695191\n..."),
///   `publishDate`.
/// - `symbol` may name several companies ("GARAN, TGB") or be empty for
///   market-wide notices (those are skipped).
class KapDisclosureDto {
  const KapDisclosureDto({
    required this.id,
    required this.symbols,
    required this.title,
    required this.publishedAt,
    this.summary,
    this.url,
  });

  /// `null` when id, symbol, title or date is missing.
  static KapDisclosureDto? fromJson(Map<String, dynamic> json) {
    final id = _text(json['id']);
    final symbols = [
      for (final part in (_text(json['symbol']) ?? '').split(','))
        if (part.trim().isNotEmpty) part.trim().toUpperCase(),
    ];
    final title = _text(json['title']);
    final publishedAt = parseDateTime(json['publishDate'] ?? json['date']);
    if (id == null || symbols.isEmpty || title == null || publishedAt == null) {
      return null;
    }
    return KapDisclosureDto(
      id: id,
      symbols: symbols,
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

  /// Upper-case stock symbols this disclosure belongs to (at least one).
  final List<String> symbols;
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
