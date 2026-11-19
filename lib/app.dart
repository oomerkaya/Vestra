import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/router/app_router.dart';
import 'package:capira/core/theme/app_theme.dart';
import 'package:capira/core/widgets/amount_display.dart';
import 'package:capira/features/market/presentation/price_refresh_controller.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:capira/features/portfolio/presentation/kap_refresh_controller.dart';
import 'package:capira/features/portfolio/presentation/snapshot_recorder.dart';
import 'package:capira/features/settings/presentation/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CapiraApp extends ConsumerWidget {
  const CapiraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the price/KAP refreshers and the daily value recorder alive.
    ref
      ..listen(priceRefreshControllerProvider, (_, _) {})
      ..listen(kapRefreshControllerProvider, (_, _) {})
      ..listen(snapshotRecorderProvider, (_, _) {});
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
      // Currency and privacy mode for every personal amount.
      builder: (context, child) => AmountDisplay(
        format: ref.watch(amountFormatProvider),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
