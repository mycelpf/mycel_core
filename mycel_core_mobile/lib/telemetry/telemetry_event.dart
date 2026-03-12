/// Structured telemetry event data class.
class TelemetryEvent {
  final String name;
  final Map<String, dynamic>? properties;
  final DateTime timestamp;
  final String sessionId;

  TelemetryEvent({
    required this.name,
    this.properties,
    required this.sessionId,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'properties': properties,
        'timestamp': timestamp.toIso8601String(),
        'session_id': sessionId,
      };
}
