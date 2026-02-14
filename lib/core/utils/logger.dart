// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  /// Debug log (only prints in debug mode)
  static void d(String message, {Object? data, StackTrace? stack}) {
    _print('D', message, data: data, stack: stack);
  }

  /// Warning log (only prints in debug mode)
  static void w(String message, {Object? data, StackTrace? stack}) {
    _print('W', message, data: data, stack: stack);
  }

  /// Error log (prints in debug mode; includes optional error + stack)
  static void e(String message, {Object? error, StackTrace? stack}) {
    _print('E', message, data: error, stack: stack);
  }

  /// Use this if you want logs in release too (rare).
  static void i(String message, {Object? data, StackTrace? stack}) {
    _print('I', message, data: data, stack: stack, force: true);
  }

  static void _print(
    String level,
    String message, {
    Object? data,
    StackTrace? stack,
    bool force = false,
  }) {
    if (!force && !kDebugMode) return;

    final ts = DateTime.now().toIso8601String();
    final base = '[$ts][$level] $message';

    debugPrint(base);
    if (data != null) debugPrint('  data: $data');
    if (stack != null) debugPrint('  stack: $stack');
  }
}
