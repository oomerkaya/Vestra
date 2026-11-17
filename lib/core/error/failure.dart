/// Domain-level error description. Exceptions are caught in the data layer
/// and converted to one of these; the UI maps them to localized messages.
sealed class Failure implements Exception {
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

/// Short-term rate limit (HTTP 429). Retry later with backoff.
final class RateLimitFailure extends Failure {
  const RateLimitFailure({this.retryAfter, String? message}) : super(message);

  final Duration? retryAfter;
}

/// Provider's monthly request quota is used up. No automatic retries until
/// the quota resets.
final class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure([super.message]);
}

/// Missing or rejected API key.
final class AuthFailure extends Failure {
  const AuthFailure({this.missingKey = false, String? message})
    : super(message);

  /// True when no key is configured at all (vs. a rejected key).
  final bool missingKey;
}

/// Local database / secure storage error.
final class StorageFailure extends Failure {
  const StorageFailure([super.message]);
}

/// Input did not pass validation. Left open so features can add typed
/// reasons (e.g. `TransactionValidationFailure`).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

/// Anything not covered above.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message]);
}
