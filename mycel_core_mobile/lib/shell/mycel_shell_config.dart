/// Configuration for [MycelShell].
///
/// Apps pass this to customize shell behavior without subclassing.
class MycelShellConfig {
  /// Base URL for the API client.
  /// Falls back to the `API_BASE_URL` compile-time environment variable.
  final String? apiBaseUrl;

  /// Whether telemetry is enabled.
  final bool telemetryEnabled;

  /// Navigation style.
  final NavigationType navigationType;

  const MycelShellConfig({
    this.apiBaseUrl,
    this.telemetryEnabled = true,
    this.navigationType = NavigationType.bottomTabs,
  });
}

/// Navigation chrome type.
enum NavigationType { bottomTabs, drawer }
