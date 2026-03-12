import 'logger.dart';

/// Creates module-scoped loggers with per-module level overrides.
///
/// Constructed by the shell. Modules access via `context.read<LoggerFactory>()`.
class LoggerFactory {
  LogLevel _defaultLevel;
  final Map<String, LogLevel> _moduleLevels = {};

  LoggerFactory({LogLevel defaultLevel = LogLevel.info})
      : _defaultLevel = defaultLevel;

  /// Create a logger bound to a module.
  Logger create(String moduleId) {
    final level = _moduleLevels[moduleId] ?? _defaultLevel;
    return Logger(moduleId, minLevel: level);
  }

  /// Change the global default level.
  void setLevel(LogLevel level) {
    _defaultLevel = level;
  }

  /// Override the level for a specific module.
  void setModuleLevel(String moduleId, LogLevel level) {
    _moduleLevels[moduleId] = level;
  }
}
