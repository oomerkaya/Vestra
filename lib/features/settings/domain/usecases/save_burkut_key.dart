import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/settings/domain/repositories/api_key_repository.dart';

enum ApiKeyValidationReason { empty, malformed }

final class ApiKeyFormatFailure extends ValidationFailure {
  const ApiKeyFormatFailure(this.reason) : super();

  final ApiKeyValidationReason reason;
}

/// Trims, checks the format locally, verifies the key with the provider
/// (costs one request) and only then stores it.
class SaveBurkutKey {
  const SaveBurkutKey(this._repository, this._validator);

  static final RegExp _allowed = RegExp(r'^[A-Za-z0-9_\-]{10,200}$');

  final ApiKeyRepository _repository;
  final ApiKeyValidator _validator;

  Future<Result<void>> call(String input) async {
    final key = input.trim();
    if (key.isEmpty) {
      return const Err(ApiKeyFormatFailure(ApiKeyValidationReason.empty));
    }
    if (!_allowed.hasMatch(key)) {
      return const Err(ApiKeyFormatFailure(ApiKeyValidationReason.malformed));
    }
    final validation = await _validator.validate(key);
    if (validation case Err(:final failure)) return Err(failure);
    return _repository.saveBurkutKey(key);
  }
}
