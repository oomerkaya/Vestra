import 'package:capira/core/error/result.dart';
import 'package:capira/features/settings/domain/repositories/api_key_repository.dart';

/// In-memory replacement for secure storage (no platform channel in tests).
class FakeApiKeyRepository implements ApiKeyRepository {
  FakeApiKeyRepository([this.key]);

  String? key;

  @override
  Future<Result<String?>> readBurkutKey() async => Success(key);

  @override
  Future<Result<void>> saveBurkutKey(String value) async {
    key = value;
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteBurkutKey() async {
    key = null;
    return const Success(null);
  }
}
