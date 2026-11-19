/// One public disclosure of a BIST company on KAP (Kamuyu Aydınlatma
/// Platformu), as delivered by Bürküt. Shown as is: no rating or summary
/// of our own, so nothing reads like investment advice.
class KapDisclosure {
  const KapDisclosure({
    required this.id,
    required this.symbol,
    required this.title,
    required this.publishedAt,
    this.summary,
    this.url,
  });

  final String id;

  /// Stock symbol, e.g. `THYAO`.
  final String symbol;

  /// Disclosure type, e.g. "Özel Durum Açıklaması (Genel)".
  final String title;

  /// Subject line, e.g. "Ekim 2026 Trafik Sonuçları"; `null` when empty.
  final String? summary;

  /// Original disclosure on kap.org.tr; `null` when not given.
  final String? url;
  final DateTime publishedAt;

  /// The most informative line: the subject if given, else the type.
  String get headline => summary ?? title;
}
