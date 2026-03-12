import 'package:flutter/widgets.dart';

import 'telemetry_service.dart';

/// Navigator observer that tracks screen views via [TelemetryService].
///
/// Attached to each tab's Navigator by the shell.
class TelemetryObserver extends NavigatorObserver {
  final TelemetryService _telemetry;

  TelemetryObserver(this._telemetry);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _trackRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _trackRoute(previousRoute);
  }

  void _trackRoute(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null) {
      _telemetry.trackScreen(name);
    }
  }
}
