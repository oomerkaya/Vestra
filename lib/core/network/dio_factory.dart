import 'package:dio/dio.dart';

/// Creates a [Dio] with sane defaults. No logging interceptor on purpose:
/// request headers may carry API keys and must never be logged.
Dio createDio({required String baseUrl, Map<String, String>? headers}) => Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json', ...?headers},
  ),
);
