// Interfaces are intentional: CLAUDE.md requires every external data source
// to sit behind one so providers can be swapped in the data layer only.
// ignore_for_file: one_member_abstracts

import 'package:capira/core/error/result.dart';
import 'package:capira/features/market/domain/entities/kap_disclosure.dart';
import 'package:capira/features/market/domain/entities/quota_usage.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/domain/entities/stock_listing.dart';

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

/// KAP disclosures.
abstract interface class DisclosureProvider {
  /// The latest disclosures of every company, newest first, in one
  /// request (Bürküt: 500, about the last 29 hours).
  Future<Result<List<KapDisclosure>>> fetchDisclosureFeed();
}

/// The provider's own quota count. Must not cost a request (Bürküt
/// `/quota`: `quotaCheckConsumesCredit: false`, verified 2026-11-19).
abstract interface class QuotaStatusProvider {
  Future<Result<QuotaStatus>> fetchQuotaStatus();
}
