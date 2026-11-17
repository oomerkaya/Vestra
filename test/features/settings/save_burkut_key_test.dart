import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/features/settings/domain/repositories/api_key_repository.dart';
import 'package:vestra/features/settings/domain/usecases/save_burkut_key.dart';

import '../../helpers/fakes.dart';

class _Validator extends Mock implements ApiKeyValidator {}

void main() {
  late FakeApiKeyRepository repo;
  late _Validator validator;
  late SaveBurkutKey save;

  setUp(() {
    repo = FakeApiKeyRepository();
    validator = _Validator();
    save = SaveBurkutKey(repo, validator);
    when(
      () => validator.validate(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  ApiKeyValidationReason? reason(Result<void> r) => switch (r) {
    Err(failure: ApiKeyFormatFailure(:final reason)) => reason,
    _ => null,
  };

  test('trims, validates and stores a valid key', () async {
    final result = await save('  bk_live_abcdef123456  ');

    expect(result.isSuccess, isTrue);
    expect(repo.key, 'bk_live_abcdef123456');
    verify(() => validator.validate('bk_live_abcdef123456')).called(1);
  });

  test('rejects empty and malformed input without a network call', () async {
    expect(reason(await save('   ')), ApiKeyValidationReason.empty);
    expect(
      reason(await save('has spaces in it')),
      ApiKeyValidationReason.malformed,
    );
    expect(reason(await save('short')), ApiKeyValidationReason.malformed);
    verifyNever(() => validator.validate(any()));
    expect(repo.key, isNull);
  });

  test('does not store a key the provider rejects', () async {
    when(
      () => validator.validate(any()),
    ).thenAnswer((_) async => const Err(AuthFailure()));

    final result = await save('bk_live_rejected_key');

    expect((result as Err).failure, isA<AuthFailure>());
    expect(repo.key, isNull);
  });
}
