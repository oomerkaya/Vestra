import 'package:capira/app.dart';
import 'package:capira/core/database/app_database.dart';
import 'package:capira/core/di/database_provider.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:capira/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:capira/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:capira/features/portfolio/domain/entities/asset.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/portfolio/presentation/backup_files.dart';
import 'package:capira/features/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

/// Keeps the "shared" file in memory and hands it back when picking.
class _MemoryFiles implements BackupFiles {
  String? sharedName;
  String? content;

  @override
  Future<void> share({
    required String fileName,
    required String content,
    required String subject,
  }) async {
    sharedName = fileName;
    this.content = content;
  }

  @override
  Future<String?> pick() async => content;
}

void main() {
  late AppDatabase db;
  late _MemoryFiles files;

  setUp(() {
    db = createTestDatabase();
    files = _MemoryFiles();
  });
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          autoRefreshEnabledProvider.overrideWithValue(false),
          apiKeyRepositoryProvider.overrideWithValue(
            FakeApiKeyRepository('bk_test_fake'),
          ),
          backupFilesProvider.overrideWithValue(files),
        ],
        child: const CapiraApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text).last;
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('export, change the portfolio, restore the backup', (
    tester,
  ) async {
    final portfolio = PortfolioRepositoryImpl(PortfolioLocalDataSource(db));
    await tester.runAsync(() async {
      final usd = (await portfolio.findOrCreateAsset(usdDraft)).valueOrNull!;
      await portfolio.insertTransaction(
        usd.id,
        draft(kind: TransactionKind.buy, qty: '300', price: '41'),
      );
    });
    await pumpApp(tester);

    await tapText(tester, 'Ayarlar');
    await tapText(tester, 'Portföyü dışa aktar');
    expect(
      files.sharedName,
      matches(RegExp(r'^capira-yedek-\d{4}-\d\d-\d\d\.json$')),
    );
    expect(files.content, contains('"USD"'));

    // After the backup the portfolio changes: USD gone, THYAO added.
    await tester.runAsync(() async {
      final current = (await portfolio.watchPortfolio().first).valueOrNull!;
      await portfolio.deleteAsset(current.single.asset.id);
      await portfolio.findOrCreateAsset(
        const AssetDraft(type: AssetType.stock, code: 'THYAO', name: 'THYAO'),
      );
    });

    await tapText(tester, 'Yedekten geri yükle');
    expect(find.text('Yedek geri yüklensin mi?'), findsOneWidget);
    await tapText(tester, 'Geri yükle');
    expect(find.text('Yedek geri yüklendi'), findsOneWidget);

    await tapText(tester, 'Portföy');
    expect(find.text('Amerikan Doları'), findsOneWidget);
    expect(find.text('THYAO'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a foreign file is rejected and nothing changes', (
    tester,
  ) async {
    files.content = '{"hello": "world"}';
    await pumpApp(tester);

    await tapText(tester, 'Ayarlar');
    await tapText(tester, 'Yedekten geri yükle');

    expect(find.text('Bu dosya bir Capira yedeği değil.'), findsOneWidget);
    expect(find.text('Yedek geri yüklensin mi?'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
