import 'package:capira/core/domain/instrument.dart';
import 'package:capira/core/router/app_routes.dart';
import 'package:capira/core/router/app_shell.dart';
import 'package:capira/features/market/presentation/market_screen.dart';
import 'package:capira/features/portfolio/domain/entities/asset_type.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:capira/features/portfolio/presentation/portfolio_screen.dart';
import 'package:capira/features/portfolio/presentation/screens/asset_detail_screen.dart';
import 'package:capira/features/portfolio/presentation/screens/edit_transaction_route.dart';
import 'package:capira/features/portfolio/presentation/screens/goal_form_screen.dart';
import 'package:capira/features/portfolio/presentation/screens/kap_screen.dart';
import 'package:capira/features/portfolio/presentation/screens/transaction_form_screen.dart';
import 'package:capira/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root navigator: detail and form screens are pushed above the bottom
/// navigation bar.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.portfolio,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.portfolio,
                builder: (context, state) => const PortfolioScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _addForm(state),
                  ),
                  GoRoute(
                    path: 'kap',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const KapScreen(),
                  ),
                  GoRoute(
                    path: 'goal',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const GoalFormScreen(),
                    routes: [
                      GoRoute(
                        path: ':goalId',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => GoalFormScreen(
                          goalId: int.parse(state.pathParameters['goalId']!),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'asset/:assetId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => AssetDetailScreen(
                      assetId: int.parse(state.pathParameters['assetId']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'transaction/:transactionId',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => EditTransactionRoute(
                          assetId: int.parse(state.pathParameters['assetId']!),
                          transactionId: int.parse(
                            state.pathParameters['transactionId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.market,
                builder: (context, state) => const MarketScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// `/portfolio/add?type=gold&code=GRAM&kind=sell` opens the form prefilled.
Widget _addForm(GoRouterState state) {
  final q = state.uri.queryParameters;
  final type = AssetType.values.asNameMap()[q['type']];
  final code = q['code'];
  final kind =
      TransactionKind.values.asNameMap()[q['kind']] ?? TransactionKind.buy;
  if (type == null || code == null || code.isEmpty) {
    return TransactionFormScreen.add(initialKind: kind);
  }
  return _PrefilledAddForm(
    instrument: (type: type, code: code),
    kind: kind,
  );
}

/// Resolves the stored asset name for a prefilled instrument.
class _PrefilledAddForm extends ConsumerWidget {
  const _PrefilledAddForm({required this.instrument, required this.kind});

  final Instrument instrument;
  final TransactionKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(holdingsProvider).value ?? const [];
    final asset = holdings
        .where(
          (h) =>
              h.asset.type == instrument.type &&
              h.asset.code == instrument.code,
        )
        .firstOrNull
        ?.asset;
    return TransactionFormScreen.add(
      initial: (instrument: instrument, name: asset?.name ?? instrument.code),
      initialKind: kind,
    );
  }
}
