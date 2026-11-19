import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/database/app_database.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/portfolio/data/backup/backup_codec.dart';
import 'package:vestra/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:vestra/features/portfolio/data/repositories/backup_repository_impl.dart';
import 'package:vestra/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:vestra/features/portfolio/domain/entities/asset.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_backup.dart';
import 'package:vestra/features/portfolio/domain/usecases/backup_use_cases.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

PortfolioBackup _backup(List<BackupAsset> assets) =>
    PortfolioBackup(exportedAt: DateTime.utc(2026, 11, 19, 18), assets: assets);

BackupAsset _thyao(List<TransactionDraft> txs) => BackupAsset(
  asset: const AssetDraft(
    type: AssetType.stock,
    code: 'THYAO',
    name: 'Türk Hava Yolları',
  ),
  transactions: txs,
);

void main() {
  group('codec', () {
    test('round trip keeps every value exactly', () {
      final original = _backup([
        _thyao([
          draft(
            kind: TransactionKind.buy,
            qty: '100',
            price: '320.125',
            date: DateTime.utc(2026, 10),
          ),
          TransactionDraft(
            kind: TransactionKind.sell,
            quantity: d('0.000001'),
            date: DateTime.utc(2026, 11, 2),
            note: 'not',
          ),
        ]),
      ]);

      final decoded = BackupCodec.decode(BackupCodec.encode(original));

      expect(decoded.exportedAt, original.exportedAt);
      final asset = decoded.assets.single;
      expect(asset.asset.code, 'THYAO');
      expect(asset.asset.name, 'Türk Hava Yolları');
      expect(asset.transactions[0].unitPriceTry, d('320.125'));
      expect(asset.transactions[1].quantity, d('0.000001'));
      expect(asset.transactions[1].unitPriceTry, isNull);
      expect(asset.transactions[1].note, 'not');
    });

    test('amounts are strings in the file', () {
      final text = BackupCodec.encode(
        _backup([
          _thyao([draft(kind: TransactionKind.buy, qty: '1.5', price: '2')]),
        ]),
      );
      final json = jsonDecode(text) as Map<String, dynamic>;
      expect(json['app'], 'vestra');
      expect(json['format'], 1);
      final tx =
          ((json['assets'] as List).single as Map)['transactions'] as List;
      expect((tx.single as Map)['quantity'], '1.5');
    });

    BackupProblem problemOf(String content) {
      try {
        BackupCodec.decode(content);
      } on BackupFailure catch (f) {
        return f.problem;
      }
      fail('expected a BackupFailure');
    }

    test('rejects other files', () {
      expect(problemOf('not json'), BackupProblem.notABackup);
      expect(
        problemOf('{"app": "other", "format": 1}'),
        BackupProblem.notABackup,
      );
      expect(
        problemOf('{"app": "vestra", "format": 2, "assets": []}'),
        BackupProblem.newerFormat,
      );
      expect(
        problemOf(
          '{"app": "vestra", "format": 1, "exportedAt": "2026-11-19", '
          '"assets": [{"type": "spaceship", "code": "X", "name": "X", '
          '"transactions": []}]}',
        ),
        BackupProblem.invalidData,
      );
    });
  });

  group('validation', () {
    test('a sale larger than the holding is rejected', () {
      final backup = _backup([
        _thyao([
          draft(kind: TransactionKind.buy, qty: '10', date: DateTime(2026)),
          draft(kind: TransactionKind.sell, qty: '11', date: DateTime(2026, 2)),
        ]),
      ]);
      expect(ReadBackup.validate(backup)?.problem, BackupProblem.invalidData);
    });

    test('duplicate assets and non-positive quantities are rejected', () {
      final buy = draft(kind: TransactionKind.buy, qty: '1');
      expect(
        ReadBackup.validate(
          _backup([
            _thyao([buy]),
            _thyao([buy]),
          ]),
        ),
        isNotNull,
      );
      expect(
        ReadBackup.validate(
          _backup([
            _thyao([draft(kind: TransactionKind.buy, qty: '0')]),
          ]),
        ),
        isNotNull,
      );
    });

    test('a valid backup passes', () {
      expect(
        ReadBackup.validate(
          _backup([
            _thyao([draft(kind: TransactionKind.buy, qty: '1')]),
          ]),
        ),
        isNull,
      );
    });
  });

  group('repository', () {
    late AppDatabase source;
    late AppDatabase target;

    setUp(() {
      source = createTestDatabase();
      target = createTestDatabase();
    });
    tearDown(() async {
      await source.close();
      await target.close();
    });

    test('export from one device, restore on another', () async {
      final portfolio = PortfolioRepositoryImpl(
        PortfolioLocalDataSource(source),
      );
      final usdAsset = (await portfolio.findOrCreateAsset(
        usdDraft,
      )).valueOrNull!;
      await portfolio.insertTransaction(
        usdAsset.id,
        draft(kind: TransactionKind.buy, qty: '300', price: '41.5'),
      );
      final gold = (await portfolio.findOrCreateAsset(
        gramGoldDraft,
      )).valueOrNull!;
      await portfolio.insertTransaction(
        gold.id,
        draft(kind: TransactionKind.buy, qty: '5'),
      );

      final exported = (await BackupRepositoryImpl(
        PortfolioLocalDataSource(source),
      ).exportBackup()).valueOrNull!;

      // The target already holds something that must disappear.
      final targetPortfolio = PortfolioRepositoryImpl(
        PortfolioLocalDataSource(target),
      );
      await targetPortfolio.findOrCreateAsset(
        const AssetDraft(type: AssetType.stock, code: 'OLD', name: 'OLD'),
      );
      final repo = BackupRepositoryImpl(PortfolioLocalDataSource(target));
      final backup = ReadBackup(repo)(exported).valueOrNull!;
      expect(await RestoreBackup(repo)(backup), isA<Success<void>>());

      final restored =
          (await targetPortfolio.watchPortfolio().first).valueOrNull!;
      expect(restored.map((a) => a.asset.code), ['USD', 'GRAM']);
      final usd = restored.first.transactions.single;
      expect(usd.quantity, d('300'));
      expect(usd.unitPriceTry, d('41.5'));
      expect(restored.last.transactions.single.unitPriceTry, isNull);
    });
  });
}
