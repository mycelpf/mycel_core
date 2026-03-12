import 'package:flutter/foundation.dart';

/// Shell controller managing badge counts and navigation state.
///
/// Constructed by MycelShell. Modules access via `context.read<ShellController>()`.
class ShellController extends ChangeNotifier {
  final Map<String, int> _badges = {};
  String _title;

  ShellController({String title = 'Mycel'}) : _title = title;

  /// Set a badge count on a nav entry.
  void setBadge(String navId, int count) {
    _badges[navId] = count;
    notifyListeners();
  }

  /// Clear a badge from a nav entry.
  void clearBadge(String navId) {
    _badges.remove(navId);
    notifyListeners();
  }

  /// Get the badge count for a nav entry.
  int getBadge(String navId) => _badges[navId] ?? 0;

  /// Get all current badges.
  Map<String, int> get badges => Map.unmodifiable(_badges);

  /// Current shell title.
  String get title => _title;

  /// Update the shell title.
  set title(String value) {
    _title = value;
    notifyListeners();
  }
}
