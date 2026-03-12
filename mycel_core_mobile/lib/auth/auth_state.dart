import 'package:flutter/foundation.dart';

/// Reactive authentication state.
///
/// Constructed by the shell from the token provided by the app's login flow.
/// Modules access this via `context.watch<AuthState>()` for reactive rebuilds
/// or `context.read<AuthState>()` for one-shot reads.
class AuthState extends ChangeNotifier {
  String _token;
  String? _userId;
  String? _email;

  AuthState({required String token}) : _token = token;

  /// Current auth token.
  String get token => _token;

  /// Current user ID (if known).
  String? get userId => _userId;

  /// Current user email (if known).
  String? get email => _email;

  /// Whether the token is present and non-empty.
  bool get isAuthenticated => _token.isNotEmpty;

  /// Update the auth token (e.g., after refresh).
  void updateToken(String token) {
    _token = token;
    notifyListeners();
  }

  /// Set user info after profile fetch.
  void setUser({String? userId, String? email}) {
    _userId = userId;
    _email = email;
    notifyListeners();
  }

  /// Clear all auth state (logout).
  void clear() {
    _token = '';
    _userId = null;
    _email = null;
    notifyListeners();
  }
}
