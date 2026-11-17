import 'package:decimal/decimal.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';

/// A single buy or sell. Holdings are always derived from these.
class AssetTransaction {
  const AssetTransaction({
    required this.id,
    required this.assetId,
    required this.kind,
    required this.quantity,
    required this.date,
    this.unitPriceTry,
    this.note,
  });

  final int id;
  final int assetId;
  final TransactionKind kind;

  /// Always positive; [kind] gives the direction.
  final Decimal quantity;

  /// Price per unit in TRY. `null` when unknown (e.g. inherited gold).
  final Decimal? unitPriceTry;
  final DateTime date;
  final String? note;

  AssetTransaction copyWith({
    TransactionKind? kind,
    Decimal? quantity,
    Decimal? Function()? unitPriceTry,
    DateTime? date,
    String? Function()? note,
  }) => AssetTransaction(
    id: id,
    assetId: assetId,
    kind: kind ?? this.kind,
    quantity: quantity ?? this.quantity,
    unitPriceTry: unitPriceTry != null ? unitPriceTry() : this.unitPriceTry,
    date: date ?? this.date,
    note: note != null ? note() : this.note,
  );
}

/// Input for a new transaction (no id yet).
class TransactionDraft {
  const TransactionDraft({
    required this.kind,
    required this.quantity,
    required this.date,
    this.unitPriceTry,
    this.note,
  });

  final TransactionKind kind;
  final Decimal quantity;
  final Decimal? unitPriceTry;
  final DateTime date;
  final String? note;
}
