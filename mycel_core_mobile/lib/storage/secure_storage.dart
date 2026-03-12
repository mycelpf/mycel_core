import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value storage for sensitive data (tokens, secrets).
///
/// Wraps [FlutterSecureStorage] (Keychain on iOS, encrypted SharedPreferences
/// + Keystore on Android). Core provides this — modules never touch platform
/// storage directly.
///
/// ```dart
/// final storage = context.read<SecureStorage>();
/// await storage.write('auth_token', token);
/// final token = await storage.read('auth_token');
/// ```
class SecureStorage {
  final FlutterSecureStorage _inner;

  SecureStorage()
      : _inner = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  /// Write a value. Overwrites if key already exists.
  Future<void> write(String key, String value) async {
    await _inner.write(key: key, value: value);
  }

  /// Read a value. Returns null if key doesn't exist.
  Future<String?> read(String key) async {
    return _inner.read(key: key);
  }

  /// Delete a single key.
  Future<void> delete(String key) async {
    await _inner.delete(key: key);
  }

  /// Delete all stored values.
  Future<void> deleteAll() async {
    await _inner.deleteAll();
  }
}
