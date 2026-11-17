import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/utils/app_logger.dart';
import 'package:vestra/features/settings/domain/repositories/api_key_repository.dart';

class ApiKeyRepositoryImpl implements ApiKeyRepository {
  const ApiKeyRepositoryImpl(this._storage);

  static const String burkutKey = 'burkut_api_key';

  final FlutterSecureStorage _storage;

  @override
  Future<Result<String?>> readBurkutKey() =>
      _guard('read', () => _storage.read(key: burkutKey));

  @override
  Future<Result<void>> saveBurkutKey(String key) =>
      _guard('write', () => _storage.write(key: burkutKey, value: key));

  @override
  Future<Result<void>> deleteBurkutKey() =>
      _guard('delete', () => _storage.delete(key: burkutKey));

  Future<Result<T>> _guard<T>(String op, Future<T> Function() body) async {
    try {
      return Success(await body());
    } on Object catch (error) {
      // Never log the error object: platform messages may echo values.
      AppLogger.error('secure storage $op failed: ${error.runtimeType}');
      return Err(StorageFailure('secure storage $op'));
    }
  }
}
