// Interfaces are intentional: CLAUDE.md requires every external data source
// to sit behind one so providers can be swapped in the data layer only.
// ignore_for_file: one_member_abstracts

import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/entities/stock_listing.dart';

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

/// BIST stock prices in one request: the whole market when `symbols` is
/// `null`, otherwise only those symbols.
abstract interface class StockPriceProvider {
  Future<Result<List<Quote>>> fetchQuotes({List<String>? symbols});
}

/// The whole BIST stock list (symbol + name) for search.
abstract interface class StockListingProvider {
  Future<Result<List<StockListing>>> fetchListings();
}

/// TEFAS investment and pension fund prices (all funds, one request).
abstract interface class FundPriceProvider {
  Future<Result<List<Quote>>> fetchFunds();
}

/// KAP disclosures. Every call is one request.
abstract interface class DisclosureProvider {
  /// Latest [limit] disclosures of one stock, newest first (Bürküt does
  /// not accept several symbols at once, verified 2026-11-19).
  Future<Result<List<KapDisclosure>>> fetchDisclosures(
    String symbol, {
    int limit,
  });

  /// One page of the general feed: every company's disclosures, newest
  /// first; page 0 is the latest.
  Future<Result<DisclosureFeedPage>> fetchDisclosureFeed({int page});
}
