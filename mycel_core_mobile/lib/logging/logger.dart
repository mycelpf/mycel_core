import 'dart:developer' as developer;

/// Log levels matching the web and service platforms.
enum LogLevel { debug, info, warn, error }

/// Structured logger with PII redaction.
///
/// Accessed via `context.read<LoggerFactory>().create('module_id')`.
class Logger {
  final String moduleId;
  final LogLevel _minLevel;

  Logger(this.moduleId, {LogLevel minLevel = LogLevel.info}) : _minLevel = minLevel;

  void debug(String message, [Map<String, dynamic>? data]) =>
      _log(LogLevel.debug, message, data);

  void info(String message, [Map<String, dynamic>? data]) =>
      _log(LogLevel.info, message, data);

  void warn(String message, [Map<String, dynamic>? data]) =>
      _log(LogLevel.warn, message, data);

  void error(String message, [Map<String, dynamic>? data]) =>
      _log(LogLevel.error, message, data);

  void _log(LogLevel level, String message, Map<String, dynamic>? data) {
    if (level.index < _minLevel.index) return;

    final redacted = _redact(message);
    developer.log(
      redacted,
      name: moduleId,
      level: _levelToInt(level),
      error: data != null ? _redactMap(data) : null,
    );
  }

  static final _emailPattern =
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b');
  static final _jwtPattern =
      RegExp(r'\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b');

  String _redact(String input) {
    return input
        .replaceAll(_emailPattern, '[EMAIL]')
        .replaceAll(_jwtPattern, '[JWT]');
  }

  Map<String, dynamic> _redactMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (key.toLowerCase().contains('password') ||
          key.toLowerCase().contains('secret') ||
          key.toLowerCase().contains('token')) {
        return MapEntry(key, '[REDACTED]');
      }
      if (value is String) return MapEntry(key, _redact(value));
      return MapEntry(key, value);
    });
  }

  int _levelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warn:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
