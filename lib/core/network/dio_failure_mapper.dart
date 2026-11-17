import 'package:dio/dio.dart';
import 'package:vestra/core/error/failure.dart';

/// Converts a [DioException] into a domain [Failure].
///
/// 429 is split into [QuotaExceededFailure] (monthly quota, no retry) and
/// [RateLimitFailure] (short-term, retry with backoff). Response bodies are
/// not copied into messages to avoid leaking anything sensitive.
Failure mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return NetworkFailure(error.type.name);
    case DioExceptionType.cancel:
      return const NetworkFailure('cancelled');
    case DioExceptionType.badCertificate:
      return const NetworkFailure('bad certificate');
    case DioExceptionType.badResponse:
      return _fromResponse(error.response);
    case DioExceptionType.unknown:
      return error.response != null
          ? _fromResponse(error.response)
          : NetworkFailure(error.message);
  }
}

Failure _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode;
  final body = response?.data;
  final errorCode = body is Map ? body['error']?.toString() : null;

  switch (status) {
    case 401:
    case 403:
      return AuthFailure(message: 'HTTP $status');
    case 429:
      final message = body is Map ? body['message']?.toString() ?? '' : '';
      if (errorCode == 'MONTHLY_QUOTA_EXCEEDED' ||
          message.toLowerCase().contains('kota') ||
          message.toLowerCase().contains('quota')) {
        return const QuotaExceededFailure('HTTP 429 quota');
      }
      return RateLimitFailure(
        retryAfter: _retryAfter(response?.headers.value('retry-after')),
        message: 'HTTP 429',
      );
  }
  return ServerFailure(statusCode: status, message: errorCode);
}

Duration? _retryAfter(String? header) {
  final seconds = int.tryParse(header ?? '');
  return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
}
