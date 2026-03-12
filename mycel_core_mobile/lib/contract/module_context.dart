import '../auth/auth_state.dart';
import '../api/api_client.dart';
import '../config/app_config.dart';
import '../errors/error_reporter.dart';
import '../logging/logger_factory.dart';
import '../telemetry/telemetry_service.dart';

/// Passed to [MycelModule.initialize] for imperative setup.
///
/// For widget-level access, modules use `context.read<ApiClient>()` etc.
/// This object is only for the one-time initialization phase.
class ModuleContext {
  final AuthState auth;
  final ApiClient apiClient;
  final AppConfig config;
  final LoggerFactory loggerFactory;
  final ErrorReporter errorReporter;
  final TelemetryService telemetry;

  const ModuleContext({
    required this.auth,
    required this.apiClient,
    required this.config,
    required this.loggerFactory,
    required this.errorReporter,
    required this.telemetry,
  });
}
