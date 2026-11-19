import 'package:capira/core/error/failure.dart';
import 'package:capira/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success exposes value and maps it', () {
      const Result<int> result = Success(2);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 2);
      expect(result.map((v) => v * 10).valueOrNull, 20);
    });

    test('Err keeps failure through map and fold', () {
      const Result<int> result = Err(NetworkFailure('offline'));

      final mapped = result.map((v) => v * 10);

      expect(mapped.isFailure, isTrue);
      expect(mapped.valueOrNull, isNull);
      expect(
        mapped.fold(onSuccess: (_) => 'ok', onFailure: (f) => f.runtimeType),
        NetworkFailure,
      );
    });
  });
}
