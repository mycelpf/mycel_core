import 'package:provider/single_child_widget.dart';

import 'module_context.dart';
import 'module_nav_entry.dart';

/// Contract that every downstream module implements.
///
/// The shell discovers capabilities through this interface.
/// Modules declare their navigation entries, providers, and
/// perform one-time imperative setup in [initialize].
abstract class MycelModule {
  /// Unique module identifier (e.g., 'iam', 'weaver', 'project_x').
  String get moduleId;

  /// Navigation entries this module contributes to the shell.
  /// Shell sorts all entries across all modules by [ModuleNavEntry.sortOrder].
  List<ModuleNavEntry> get navEntries;

  /// Providers this module needs registered at app scope.
  ///
  /// These are mounted BELOW core's providers in the widget tree,
  /// so they CAN depend on ApiClient, AuthState, TelemetryService.
  List<SingleChildWidget> get providers;

  /// Called once during shell initialization, BEFORE UI builds.
  ///
  /// Module receives cross-cutting services for imperative setup
  /// (warm caches, register interceptors, check feature flags).
  Future<void> initialize(ModuleContext context);

  /// Called when the app returns to the foreground. Default no-op.
  void onForeground() {}

  /// Called when the app goes to the background. Default no-op.
  void onBackground() {}

  /// Called on memory pressure. Default no-op.
  void onLowMemory() {}
}
