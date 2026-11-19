import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';

/// Locally stored KAP disclosures of held stocks and their fetch times.
abstract interface class DisclosureRepository {
  /// Every stored disclosure, newest first, live.
  Stream<Result<List<KapDisclosure>>> watchAll();

  /// When [symbol] was last fetched on its own.
  Future<DateTime?> lastFetchedAt(String symbol);

  /// When the general feed was last read.
  Future<DateTime?> lastFeedAt();

  /// Fetches one stock (one request) and stores its disclosures.
  /// Returns how many were stored.
  Future<Result<int>> refresh(String symbol);

  /// Reads the general feed (one request, more if the previous read is
  /// further back than one page) and stores the disclosures of [held]
  /// stocks. Returns how many were stored.
  Future<Result<int>> refreshFeed(Set<String> held);

  /// Drops disclosures of stocks that are no longer held and old ones.
  Future<Result<void>> keepOnly(Set<String> symbols);

  /// When the user last opened the disclosure list, live.
  Stream<DateTime?> watchSeenAt();

  Future<Result<void>> markSeen(DateTime at);
}
