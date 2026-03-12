import 'package:flutter/material.dart';

import 'auth_state.dart';

/// Wraps the shell's content and redirects when the token becomes invalid.
///
/// Listens to [AuthState] and calls [onAuthExpired] when the token is cleared.
class AuthGate extends StatefulWidget {
  final AuthState authState;
  final VoidCallback onAuthExpired;
  final Widget child;

  const AuthGate({
    required this.authState,
    required this.onAuthExpired,
    required this.child,
    super.key,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    widget.authState.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    widget.authState.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!widget.authState.isAuthenticated) {
      widget.onAuthExpired();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
