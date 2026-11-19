import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';

/// Locally stored KAP disclosures and when each stock was last fetched.
abstract interface class DisclosureRepository {
  /// Every stored disclosure, newest first, live.
  Stream<Result<List<KapDisclosure>>> watchAll();

  /// When [symbol]'s disclosures were last fetched successfully.
  Future<DateTime?> lastFetchedAt(String symbol);

  /// Fetches [symbol] (one request) and replaces its stored disclosures.
  /// Returns how many were stored.
  Future<Result<int>> refresh(String symbol);

  /// Drops stored disclosures of stocks that are no longer held.
  Future<Result<void>> keepOnly(Set<String> symbols);
}
