import 'package:flutter/widgets.dart';

/// Describes a navigation entry that a module contributes to the shell.
///
/// The shell collects entries from all modules, sorts by [sortOrder],
/// and builds the tab bar / drawer from them.
class ModuleNavEntry {
  /// Unique entry ID (e.g., 'iam_profile', 'weaver_dashboard').
  final String id;

  /// Label displayed in tab bar or drawer.
  final String label;

  /// Icon for the navigation entry.
  final IconData icon;

  /// Sort order. Shell sorts all entries from all modules by this.
  /// Lower = appears first (leftmost tab, top of drawer).
  final int sortOrder;

  /// Builder for the root widget of this entry.
  ///
  /// Module owns EVERYTHING from here down — own Navigator,
  /// own stack, modals, transitions. Shell does not reach inside.
  final Widget Function() rootBuilder;

  /// Whether this entry appears in navigation chrome.
  /// False = reachable via deep link or programmatic nav only.
  final bool showInNav;

  const ModuleNavEntry({
    required this.id,
    required this.label,
    required this.icon,
    required this.sortOrder,
    required this.rootBuilder,
    this.showInNav = true,
  });
}
