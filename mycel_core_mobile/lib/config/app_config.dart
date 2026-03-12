/// Mycel Core Mobile - Centralized Configuration.
///
/// Provides endpoint catalog and runtime configuration.
/// Modules resolve service URLs via [getServiceUrl] — never hardcode URLs.
///
/// ```dart
/// final config = context.read<AppConfig>();
/// final iamUrl = config.getServiceUrl('iam');
/// ```
class AppConfig {
  /// Current environment identifier.
  final String environment;

  final Map<String, String> _serviceRegistry;
  final Map<String, dynamic> _values;

  AppConfig({
    required this.environment,
    Map<String, String>? services,
    Map<String, dynamic>? values,
  })  : _serviceRegistry = services ?? {},
        _values = values ?? {};

  /// Resolve a service identifier to its base URL.
  ///
  /// Throws [ConfigError] if no URL is configured for [serviceId].
  String getServiceUrl(String serviceId) {
    final url = _serviceRegistry[serviceId.toLowerCase()];
    if (url == null || url.isEmpty) {
      throw ConfigError(
        "No URL configured for service '$serviceId'. "
        "Pass it via --dart-define or remote config.",
      );
    }
    // Strip trailing slashes
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Get a config value by key, with optional default.
  T get<T>(String key, {T? defaultValue}) {
    final val = _values[key];
    if (val is T) return val;
    return defaultValue as T;
  }

  /// Factory: build from compile-time --dart-define values.
  ///
  /// Convention: SERVICE_{ID}_URL defines a service endpoint.
  /// Example: --dart-define=SERVICE_IAM_URL=http://localhost:1212
  factory AppConfig.fromEnvironment() {
    const env = String.fromEnvironment('MYCEL_ENV', defaultValue: 'dev');

    // Build service registry from known --dart-define keys.
    // Dart's String.fromEnvironment requires compile-time constants,
    // so we enumerate known services. Add entries as new services appear.
    final services = <String, String>{};
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (apiBaseUrl.isNotEmpty) services['api'] = apiBaseUrl;
    const iamUrl = String.fromEnvironment('SERVICE_IAM_URL');
    if (iamUrl.isNotEmpty) services['iam'] = iamUrl;
    const weaverUrl = String.fromEnvironment('SERVICE_WEAVER_URL');
    if (weaverUrl.isNotEmpty) services['weaver'] = weaverUrl;

    return AppConfig(environment: env, services: services);
  }

  /// Factory: build from environment + optional remote config overlay.
  static Future<AppConfig> load({String? remoteConfigUrl}) async {
    final base = AppConfig.fromEnvironment();
    // Remote config fetch is optional — degrade gracefully if unavailable.
    // Subclass or extend this method to integrate remote config providers.
    return base;
  }
}

/// Thrown when a required config value is missing.
class ConfigError implements Exception {
  final String message;
  const ConfigError(this.message);

  @override
  String toString() => 'ConfigError: $message';
}
