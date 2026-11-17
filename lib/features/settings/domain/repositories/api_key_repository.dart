import 'package:vestra/core/error/result.dart';

/// Secret API keys. Backed by encrypted platform storage, never by the
/// database, logs or source code.
abstract interface class ApiKeyRepository {
  /// `Success(null)` when no key is stored.
  Future<Result<String?>> readBurkutKey();

  Future<Result<void>> saveBurkutKey(String key);

  Future<Result<void>> deleteBurkutKey();
}

/// Checks a key against the provider before it is saved.
// One method by design: implemented by the market data layer.
// ignore: one_member_abstracts
abstract interface class ApiKeyValidator {
  Future<Result<void>> validate(String key);
}
