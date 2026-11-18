import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';

/// Route paths. Detail and form screens are pushed above the bottom
/// navigation (root navigator).
abstract final class AppRoutes {
  static const portfolio = '/portfolio';
  static const market = '/market';
  static const settings = '/settings';

  static const addTransaction = '/portfolio/add';
  static const assetDetailPattern = '/portfolio/asset/:assetId';
  static const editTransactionPattern =
      '/portfolio/asset/:assetId/transaction/:transactionId';

  static String assetDetail(int assetId) => '/portfolio/asset/$assetId';

  static String editTransaction(int assetId, int transactionId) =>
      '/portfolio/asset/$assetId/transaction/$transactionId';

  /// Add form prefilled with an instrument and buy/sell.
  static String addTransactionFor(
    Instrument instrument, {
    TransactionKind kind = TransactionKind.buy,
  }) => Uri(
    path: addTransaction,
    queryParameters: {
      'type': instrument.type.name,
      'code': instrument.code,
      'kind': kind.name,
    },
  ).toString();
}
