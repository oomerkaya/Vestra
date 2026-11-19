import 'package:capira/core/error/failure.dart';

/// Outcome of an operation that can fail without throwing.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Err<T>;

  /// Returns the value or `null` on failure.
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Err() => null,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Err(:final failure) => onFailure(failure),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Err(:final failure) => Err(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// Named `Err` to avoid clashing with the [Failure] error type.
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
