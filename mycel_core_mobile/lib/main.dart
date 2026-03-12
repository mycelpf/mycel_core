import 'package:flutter/material.dart';
import 'mycel_core_mobile.dart';

void main() => runApp(const MycelCoreShell());

/// The bare core mobile shell — no modules registered.
///
/// This is the mobile equivalent of mycel_core_web's standalone shell.
/// Renders the shell chrome (nav, providers, auth gate) with an empty
/// module list. Downstream apps (e.g. mycel_iam_mobile) provide their
/// own main.dart that passes [MycelModule] implementations into
/// [MycelShell], populating the navigation and content areas.
class MycelCoreShell extends StatelessWidget {
  const MycelCoreShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MycelShell(
      authToken: '',
      modules: [],
      config: const MycelShellConfig(
        telemetryEnabled: false,
      ),
    );
  }
}
