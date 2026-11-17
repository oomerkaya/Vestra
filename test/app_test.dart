import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VestraApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on portfolio tab with empty state', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Portföyün boş'), findsOneWidget);
  });

  testWidgets('switches to dark theme from settings', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karanlık'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).last);
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
