import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/router/app_router.dart';
import 'package:vestra/core/theme/app_theme.dart';
import 'package:vestra/features/market/presentation/price_refresh_controller.dart';
import 'package:vestra/features/portfolio/presentation/kap_refresh_controller.dart';
import 'package:vestra/features/settings/presentation/theme_mode_provider.dart';

class VestraApp extends ConsumerWidget {
  const VestraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the price and KAP refreshers alive for the whole app session.
    ref
      ..listen(priceRefreshControllerProvider, (_, _) {})
      ..listen(kapRefreshControllerProvider, (_, _) {});
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: const Locale('tr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
