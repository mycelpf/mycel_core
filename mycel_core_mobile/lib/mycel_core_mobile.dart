/// Mycel Core Mobile — public API.
///
/// Import this single file to access the shell, module contract,
/// and all cross-cutting services.
library mycel_core_mobile;

// Shell
export 'shell/mycel_shell.dart';
export 'shell/mycel_shell_config.dart';
export 'shell/shell_controller.dart';
export 'shell/deep_link_handler.dart';

// Module contract
export 'contract/mycel_module.dart';
export 'contract/module_nav_entry.dart';
export 'contract/module_context.dart';

// Cross-cutting services
export 'auth/auth_state.dart';
export 'auth/auth_gate.dart';
export 'api/api_client.dart';
export 'api/interceptor.dart';
export 'api/interceptors/retry_interceptor.dart';
export 'api/interceptors/timeout_interceptor.dart';
export 'telemetry/telemetry_service.dart';
export 'telemetry/telemetry_event.dart';
export 'telemetry/telemetry_observer.dart';

// Feature Flags
export 'flags/feature_flag_service.dart';

// Tracing
export 'tracing/tracer.dart';
export 'tracing/trace_interceptor.dart';

// Logging
export 'logging/logger.dart';
export 'logging/logger_factory.dart';

// Errors
export 'errors/error_classification.dart';
export 'errors/error_reporter.dart';

// Config
export 'config/app_config.dart';

// Storage
export 'storage/secure_storage.dart';
export 'storage/cache_storage.dart';

// Notifications
export 'notifications/notification_service.dart';

// Lifecycle
export 'lifecycle/lifecycle_manager.dart';
export 'lifecycle/update_gate.dart';

// Theme
export 'theme/mycel_theme.dart';
export 'theme/tokens.dart';
