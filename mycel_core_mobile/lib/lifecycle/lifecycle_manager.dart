import 'package:flutter/widgets.dart';

import '../contract/mycel_module.dart';

/// Distributes app lifecycle events to all registered modules.
///
/// Constructed by the shell and listens to [WidgetsBindingObserver] events.
class LifecycleManager extends WidgetsBindingObserver {
  final List<MycelModule> _modules;

  LifecycleManager(this._modules) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        for (final m in _modules) {
          m.onForeground();
        }
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        for (final m in _modules) {
          m.onBackground();
        }
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void didHaveMemoryPressure() {
    for (final m in _modules) {
      m.onLowMemory();
    }
  }

  /// Call during shell disposal.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
