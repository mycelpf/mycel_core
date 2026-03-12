import 'dart:math';

/// Lightweight tracer generating W3C Trace Context headers.
class Tracer {
  static final _random = Random.secure();
  String? _activeTraceId;

  /// Start a new span.
  Span startSpan(String name, {String? parentSpanId}) {
    final traceId = _activeTraceId ?? _randomHex(16);
    final spanId = _randomHex(8);
    if (_activeTraceId == null) _activeTraceId = traceId;

    return Span._(
      traceId: traceId,
      spanId: spanId,
      parentSpanId: parentSpanId,
      name: name,
      tracer: this,
    );
  }

  void _endRoot(String traceId) {
    if (_activeTraceId == traceId) _activeTraceId = null;
  }

  String? get activeTraceId => _activeTraceId;

  static String _randomHex(int bytes) {
    return List.generate(bytes, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

class Span {
  final String traceId;
  final String spanId;
  final String? parentSpanId;
  final String name;
  final DateTime startTime;
  final Tracer _tracer;

  Span._({
    required this.traceId,
    required this.spanId,
    this.parentSpanId,
    required this.name,
    required Tracer tracer,
  })  : startTime = DateTime.now(),
        _tracer = tracer;

  /// Build a W3C `traceparent` header value.
  String get traceparent => '00-$traceId-$spanId-01';

  void end() {
    if (parentSpanId == null) {
      _tracer._endRoot(traceId);
    }
  }
}
