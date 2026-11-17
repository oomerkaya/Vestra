// Interfaces are intentional: CLAUDE.md requires every external data source
// to sit behind one so providers can be swapped in the data layer only.
// ignore_for_file: one_member_abstracts

import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';

/// Every external price source sits behind one of these interfaces, so a
/// provider can be swapped by changing only the data layer.

/// Currency rates in TRY.
abstract interface class FxRateProvider {
  Future<Result<List<Quote>>> fetchRates();
}

/// Gold and silver prices in TRY.
abstract interface class MetalPriceProvider {
  Future<Result<List<Quote>>> fetchPrices();
}

/// BIST stock prices for the given symbols (batched in one request).
abstract interface class StockPriceProvider {
  Future<Result<List<Quote>>> fetchQuotes(List<String> symbols);
}
