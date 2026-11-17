import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';

/// Something the user holds: a currency, a gold/silver unit or a stock.
/// Identity is `(type, code)`; only one row exists per pair.
class Asset {
  const Asset({
    required this.id,
    required this.type,
    required this.code,
    required this.name,
  });

  final int id;
  final AssetType type;

  /// Machine code, e.g. `USD`, `GRAM`, `CEYREK`, `SILVER_GRAM`, `THYAO`.
  final String code;

  /// Display name, e.g. "Amerikan Doları".
  final String name;
}

/// Input for creating an asset when it does not exist yet.
class AssetDraft {
  const AssetDraft({
    required this.type,
    required this.code,
    required this.name,
  });

  final AssetType type;
  final String code;
  final String name;
}
