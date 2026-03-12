import '../contract/module_nav_entry.dart';

/// Resolved deep link result.
class DeepLinkResult {
  final String moduleId;
  final String screenId;
  final Map<String, String> params;

  const DeepLinkResult({
    required this.moduleId,
    required this.screenId,
    this.params = const {},
  });
}

/// Resolves URI paths to module nav entries.
class DeepLinkHandler {
  final List<ModuleNavEntry> _entries;

  DeepLinkHandler(this._entries);

  /// Resolve a URI path to a nav entry index.
  /// Returns -1 if no match found.
  int resolveToIndex(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return 0;

    // Match by nav entry id
    final targetId = segments.first;
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].id == targetId) return i;
    }

    return -1;
  }

  /// Resolve a URI path to a DeepLinkResult.
  DeepLinkResult? resolve(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    final targetId = segments.first;
    for (final entry in _entries) {
      if (entry.id == targetId) {
        return DeepLinkResult(
          moduleId: entry.id,
          screenId: segments.length > 1 ? segments[1] : 'root',
          params: segments.length > 2
              ? {'id': segments[2]}
              : {},
        );
      }
    }

    return null;
  }
}
