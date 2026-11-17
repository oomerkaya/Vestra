/// Domain-level error description. Exceptions are caught in the data layer
/// and converted to one of these; the UI maps them to localized messages.
sealed class Failure {
  const Failure([this.message]);

  /// Developer-facing detail. Never shown to users, never contains secrets.
  final String? message;
}

/// No connectivity or the request timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

/// Remote service answered with an error status.
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, String? message}) : super(message);

  final int? statusCode;
}

/// HTTP 429 or a known quota limit was hit.
final class RateLimitFailure extends Failure {
  const RateLimitFailure({this.retryAfter, String? message}) : super(message);

  final Duration? retryAfter;
}

/// Missing or rejected API key.
final class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

/// Local database / secure storage error.
final class StorageFailure extends Failure {
  const StorageFailure([super.message]);
}

/// Input did not pass validation.
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

/// Anything not covered above.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message]);
}
