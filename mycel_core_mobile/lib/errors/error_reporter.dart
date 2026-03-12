import 'dart:developer' as developer;

import 'error_classification.dart';

/// Captures and reports errors.
///
/// Constructed by the shell. Modules access via `context.read<ErrorReporter>()`.
class ErrorReporter {
  final bool enabled;
  final Map<String, Map<String, dynamic>> _contextBag = {};
  Map<String, dynamic>? _user;

  ErrorReporter({this.enabled = true});

  /// Capture an error with optional context.
  void capture(Object error, {Map<String, dynamic>? context, StackTrace? stackTrace}) {
    if (!enabled) return;

    developer.log(
      'Error captured: $error',
      name: 'ErrorReporter',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Set persistent context that will be attached to all future captures.
  void setContext(String key, Map<String, dynamic> value) {
    _contextBag[key] = value;
  }

  /// Set the current user for error reports.
  void setUser({required String id, Map<String, dynamic>? extra}) {
    _user = {'id': id, ...?extra};
  }

  /// Classify an error.
  ErrorClassification classify(Object error) {
    if (error is HttpErrorWithStatus) {
      return classifyHttpStatus(error.statusCode);
    }
    return ErrorClassification.internal;
  }
}

/// Mixin for errors that carry an HTTP status code.
mixin HttpErrorWithStatus {
  int get statusCode;
}
