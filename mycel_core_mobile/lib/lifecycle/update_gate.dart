import 'package:flutter/material.dart';

/// Blocks the UI with a forced update screen when a newer version is required.
///
/// Usage:
/// ```dart
/// UpdateGate(
///   currentVersion: '1.0.0',
///   minimumVersion: remoteConfig.minimumVersion,
///   updateUrl: 'https://apps.apple.com/...',
///   child: MycelShell(...),
/// )
/// ```
class UpdateGate extends StatelessWidget {
  final String currentVersion;
  final String? minimumVersion;
  final String? updateUrl;
  final Widget child;

  const UpdateGate({
    required this.currentVersion,
    this.minimumVersion,
    this.updateUrl,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (minimumVersion != null && _isOutdated(currentVersion, minimumVersion!)) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.system_update, size: 64, color: Colors.teal),
                  const SizedBox(height: 24),
                  const Text(
                    'Update Required',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please update to version $minimumVersion or later to continue.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return child;
  }

  /// Simple semver comparison: returns true if current < minimum.
  static bool _isOutdated(String current, String minimum) {
    final currentParts = current.split('.').map(int.tryParse).toList();
    final minimumParts = minimum.split('.').map(int.tryParse).toList();

    for (int i = 0; i < 3; i++) {
      final c = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      final m = i < minimumParts.length ? (minimumParts[i] ?? 0) : 0;
      if (c < m) return true;
      if (c > m) return false;
    }
    return false;
  }
}
