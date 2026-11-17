import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Minimal logger on top of `dart:developer`. Debug builds only.
///
/// Never pass API keys, auth headers or full request URLs containing
/// secrets to these methods.
abstract final class AppLogger {
  static void debug(String message, {String tag = 'vestra'}) =>
      _log(message, tag: tag, level: 500);

  static void info(String message, {String tag = 'vestra'}) =>
      _log(message, tag: tag, level: 800);

  static void warning(String message, {String tag = 'vestra'}) =>
      _log(message, tag: tag, level: 900);

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = 'vestra',
  }) => _log(
    message,
    tag: tag,
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );

  static void _log(
    String message, {
    required String tag,
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    developer.log(
      message,
      name: tag,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
