import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A reported error with metadata.
class ErrorReport {
  final Object error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final String? context;

  const ErrorReport({
    required this.error,
    this.stackTrace,
    required this.timestamp,
    this.context,
  });

  @override
  String toString() =>
      '[$timestamp] ${context != null ? '($context) ' : ''}$error';
}

/// Global error reporter. Captures errors in a ring buffer and logs to
/// console in debug mode. Designed to be swapped with Sentry/Crashlytics
/// by overriding the provider in main.dart.
class ErrorReporter {
  static const _maxErrors = 50;
  final _errors = Queue<ErrorReport>();

  /// All captured errors (most recent last), capped at [_maxErrors].
  List<ErrorReport> get errors => _errors.toList();

  /// Report an error. In debug mode, prints to console.
  void reportError(Object error, StackTrace? stackTrace, {String? context}) {
    final report = ErrorReport(
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: context,
    );

    // Ring buffer — drop oldest when full
    if (_errors.length >= _maxErrors) _errors.removeFirst();
    _errors.add(report);

    // Send to Sentry
    Sentry.captureException(error, stackTrace: stackTrace);

    if (kDebugMode) {
      debugPrint('══════ ERROR REPORTED ══════');
      if (context != null) debugPrint('Context: $context');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack: $stackTrace');
      }
      debugPrint('════════════════════════════');
    }
  }

  /// Log a non-fatal message.
  void log(String message) {
    if (kDebugMode) {
      debugPrint('[ErrorReporter] $message');
    }
  }
}
