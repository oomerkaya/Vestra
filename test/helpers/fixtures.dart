import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:decimal/decimal.dart';

Decimal d(String value) => Decimal.parse(value);

const usd = Asset(
  id: 1,
  type: AssetType.currency,
  code: 'USD',
  name: 'Amerikan Doları',
);

const usdDraft = AssetDraft(
  type: AssetType.currency,
  code: 'USD',
  name: 'Amerikan Doları',
);

const gramGoldDraft = AssetDraft(
  type: AssetType.gold,
  code: 'GRAM',
  name: 'Gram Altın',
);

AssetTransaction tx({
  required int id,
  required TransactionKind kind,
  required String qty,
  String? price,
  DateTime? date,
  int assetId = 1,
}) => AssetTransaction(
  id: id,
  assetId: assetId,
  kind: kind,
  quantity: d(qty),
  unitPriceTry: price == null ? null : d(price),
  date: date ?? DateTime(2026, 1, id),
);

TransactionDraft draft({
  required TransactionKind kind,
  required String qty,
  String? price,
  DateTime? date,
}) => TransactionDraft(
  kind: kind,
  quantity: d(qty),
  unitPriceTry: price == null ? null : d(price),
  date: date ?? DateTime(2026, 6),
);
