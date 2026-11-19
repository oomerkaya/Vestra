import 'package:capira/core/error/result.dart';
import 'package:capira/features/market/domain/entities/kap_disclosure.dart';

/// Locally stored KAP disclosures (all companies, last 30 days).
abstract interface class DisclosureRepository {
  /// Stored disclosures of [symbols], newest first, live.
  Stream<Result<List<KapDisclosure>>> watchForSymbols(Set<String> symbols);

  /// When the general feed was last read successfully.
  Future<DateTime?> lastFeedAt();

  /// Reads the general feed (one request) and stores every disclosure.
  /// Returns how many were stored.
  Future<Result<int>> refreshFeed();

  /// Deletes disclosures older than 30 days.
  Future<Result<void>> prune();

  /// When the user last opened the disclosure list, live.
  Stream<DateTime?> watchSeenAt();

  Future<Result<void>> markSeen(DateTime at);
}
