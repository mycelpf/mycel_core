import 'package:flutter/material.dart';

/// Client notification service for toast and push notifications.
///
/// Constructed by the shell. Modules access via `context.read<NotificationService>()`.
class NotificationService {
  final GlobalKey<NavigatorState>? _navigatorKey;

  NotificationService({GlobalKey<NavigatorState>? navigatorKey})
      : _navigatorKey = navigatorKey;

  /// Show a toast notification.
  void showToast(
    String message, {
    String? title,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        duration: duration,
        backgroundColor: _colorForType(type),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF10B981);
      case NotificationType.error:
        return const Color(0xFFEF4444);
      case NotificationType.warning:
        return const Color(0xFFF59E0B);
      case NotificationType.info:
        return const Color(0xFF3B82F6);
    }
  }
}

enum NotificationType { success, error, warning, info }
