import 'dart:convert';
import 'package:http/http.dart' as http;

/// Feature flag service with TTL-cached remote fetching.
///
/// Falls back to static/last-cached values when offline.
///
/// ```dart
/// final flags = context.read<FeatureFlagService>();
/// if (flags.isEnabled('new_checkout_flow')) { ... }
/// ```
class FeatureFlagService {
  final Map<String, dynamic> _staticFlags;
  Map<String, dynamic> _cache = {};
  final Duration cacheTtl;
  final String? remoteUrl;
  DateTime _lastFetch = DateTime.fromMillisecondsSinceEpoch(0);

  FeatureFlagService({
    Map<String, dynamic>? staticFlags,
    this.cacheTtl = const Duration(minutes: 5),
    this.remoteUrl,
  }) : _staticFlags = staticFlags ?? {};

  /// Check whether a feature flag is enabled.
  bool isEnabled(String key, {bool defaultValue = false}) {
    final val = _resolve(key);
    if (val == null) return defaultValue;
    if (val is bool) return val;
    if (val is String) return ['true', '1', 'yes', 'on'].contains(val.toLowerCase());
    return false;
  }

  /// Get a feature flag value (arbitrary type).
  T getValue<T>(String key, {T? defaultValue}) {
    final val = _resolve(key);
    if (val is T) return val;
    return defaultValue as T;
  }

  /// Return all resolved flags.
  Map<String, dynamic> allFlags() {
    return {..._staticFlags, ..._cache};
  }

  dynamic _resolve(String key) {
    if (_cache.containsKey(key)) return _cache[key];
    return _staticFlags[key];
  }

  /// Refresh flags from remote provider.
  Future<void> refresh() async {
    final now = DateTime.now();
    if (now.difference(_lastFetch) < cacheTtl) return;

    if (remoteUrl != null) {
      try {
        final response = await http.get(Uri.parse(remoteUrl!));
        if (response.statusCode == 200) {
          _cache = jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (_) {
        // Degrade gracefully — keep using static/last-cached flags
      }
    }
    _lastFetch = now;
  }

  /// Manually set a static flag (useful for testing).
  void setStatic(String key, dynamic value) {
    _staticFlags[key] = value;
  }
}
