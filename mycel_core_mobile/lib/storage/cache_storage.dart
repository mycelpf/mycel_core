import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive cached data with TTL and eviction.
///
/// Uses [SharedPreferences] for persistence. Each entry stores
/// a JSON wrapper with the value and expiry timestamp.
///
/// ```dart
/// final cache = context.read<CacheStorage>();
/// await cache.put('user_profile', profileJson, ttl: Duration(minutes: 30));
/// final profile = await cache.get<Map<String, dynamic>>('user_profile');
/// ```
class CacheStorage {
  static const _prefix = 'mycel_cache_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Store a value with optional TTL. If [ttl] is null, the entry never expires.
  Future<void> put(String key, dynamic value, {Duration? ttl}) async {
    final prefs = await _storage;
    final wrapper = {
      'value': value,
      'expires': ttl != null
          ? DateTime.now().add(ttl).millisecondsSinceEpoch
          : null,
    };
    await prefs.setString('$_prefix$key', jsonEncode(wrapper));
  }

  /// Retrieve a cached value. Returns null if expired or missing.
  Future<T?> get<T>(String key) async {
    final prefs = await _storage;
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return null;

    try {
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final expires = wrapper['expires'] as int?;
      if (expires != null && DateTime.now().millisecondsSinceEpoch > expires) {
        // Expired — clean up and return null
        await prefs.remove('$_prefix$key');
        return null;
      }
      return wrapper['value'] as T?;
    } catch (_) {
      return null;
    }
  }

  /// Remove a single cached entry.
  Future<void> evict(String key) async {
    final prefs = await _storage;
    await prefs.remove('$_prefix$key');
  }

  /// Remove all cached entries managed by this storage.
  Future<void> evictAll() async {
    final prefs = await _storage;
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
