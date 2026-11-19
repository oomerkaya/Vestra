import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:vestra/features/portfolio/domain/entities/asset.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_backup.dart';

/// Vestra backup file, format 1 (JSON, UTF-8):
///
/// ```json
/// {
///   "app": "vestra",
///   "format": 1,
///   "exportedAt": "2026-11-19T18:00:00.000Z",
///   "assets": [
///     {
///       "type": "stock", "code": "THYAO", "name": "THYAO",
///       "transactions": [
///         {"kind": "buy", "quantity": "100", "unitPriceTry": "320.5",
///          "date": "2026-10-01T00:00:00.000Z", "note": null}
///       ]
///     }
///   ]
/// }
/// ```
///
/// Amounts are strings so no precision is lost (`Decimal`). Enum values are
/// the Dart enum names, as in the database.
abstract final class BackupCodec {
  static const String appId = 'vestra';
  static const int format = 1;

  static String encode(PortfolioBackup backup) =>
      const JsonEncoder.withIndent('  ').convert({
        'app': appId,
        'format': format,
        'exportedAt': backup.exportedAt.toUtc().toIso8601String(),
        'assets': [
          for (final entry in backup.assets)
            {
              'type': entry.asset.type.name,
              'code': entry.asset.code,
              'name': entry.asset.name,
              'transactions': [
                for (final tx in entry.transactions)
                  {
                    'kind': tx.kind.name,
                    'quantity': tx.quantity.toString(),
                    'unitPriceTry': tx.unitPriceTry?.toString(),
                    'date': tx.date.toUtc().toIso8601String(),
                    'note': tx.note,
                  },
              ],
            },
        ],
      });

  /// Throws [BackupFailure] when [content] is not a readable backup.
  static PortfolioBackup decode(String content) {
    final Object? json;
    try {
      json = jsonDecode(content);
    } on FormatException {
      throw const BackupFailure(BackupProblem.notABackup);
    }
    if (json is! Map<String, dynamic> || json['app'] != appId) {
      throw const BackupFailure(BackupProblem.notABackup);
    }
    final version = json['format'];
    if (version is! int) throw const BackupFailure(BackupProblem.notABackup);
    if (version > format) throw const BackupFailure(BackupProblem.newerFormat);

    try {
      return PortfolioBackup(
        exportedAt: DateTime.parse(json['exportedAt'] as String),
        assets: [
          for (final a in json['assets'] as List<dynamic>)
            _asset(a as Map<String, dynamic>),
        ],
      );
    } on BackupFailure {
      rethrow;
    } on Object {
      throw const BackupFailure(BackupProblem.invalidData);
    }
  }

  static BackupAsset _asset(Map<String, dynamic> json) => BackupAsset(
    asset: AssetDraft(
      type: AssetType.values.byName(json['type'] as String),
      code: (json['code'] as String).trim().toUpperCase(),
      name: json['name'] as String,
    ),
    transactions: [
      for (final t in json['transactions'] as List<dynamic>)
        _transaction(t as Map<String, dynamic>),
    ],
  );

  static TransactionDraft _transaction(Map<String, dynamic> json) {
    final price = json['unitPriceTry'] as String?;
    return TransactionDraft(
      kind: TransactionKind.values.byName(json['kind'] as String),
      quantity: Decimal.parse(json['quantity'] as String),
      unitPriceTry: price == null ? null : Decimal.parse(price),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}
