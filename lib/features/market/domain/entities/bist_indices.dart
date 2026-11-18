/// BIST 30 / BIST 100 constituents for one index period, loaded from
/// `assets/data/bist_indices.json` (Bürküt has no index data). Borsa
/// İstanbul reviews the indices quarterly, so the file needs updating.
class BistIndices {
  const BistIndices({
    required this.validUntil,
    required this.bist30,
    required this.bist100,
  });

  factory BistIndices.fromJson(Map<String, dynamic> json) => BistIndices(
    validUntil: DateTime.parse(json['validUntil'] as String),
    bist30: {for (final s in json['XU030'] as List<dynamic>) s as String},
    bist100: {for (final s in json['XU100'] as List<dynamic>) s as String},
  );

  static final empty = BistIndices(
    validUntil: DateTime(2000),
    bist30: const {},
    bist100: const {},
  );

  /// Last day of the period the lists were published for.
  final DateTime validUntil;
  final Set<String> bist30;
  final Set<String> bist100;

  /// True after [validUntil]: the composition may have changed.
  bool isOutdated(DateTime now) => now.isAfter(
    DateTime(validUntil.year, validUntil.month, validUntil.day + 1),
  );
}
