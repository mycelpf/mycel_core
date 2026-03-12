import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart';

import 'telemetry_event.dart';

/// Event-based telemetry service with OTel tracing support.
///
/// Constructed by the shell. Modules emit custom events via this service.
/// When [enabled] is false, all methods are no-ops.
///
/// OTel tracing is initialized when [otelEndpoint] is provided.
/// Mobile runs natively on the host and reaches the collector via host-exposed
/// port (e.g., http://localhost:4318).
class TelemetryService {
  final bool enabled;
  final String? endpoint;
  final String? otelEndpoint;
  final int batchSize;
  final Duration flushInterval;

  final List<TelemetryEvent> _queue = [];
  late final String _sessionId;
  Timer? _timer;
  Tracer? _tracer;
  bool _otelInitialized = false;

  TelemetryService({
    this.enabled = true,
    this.endpoint,
    this.otelEndpoint,
    this.batchSize = 20,
    this.flushInterval = const Duration(seconds: 30),
  }) {
    _sessionId = '${DateTime.now().millisecondsSinceEpoch}-'
        '${(DateTime.now().microsecond).toRadixString(36)}';
    if (enabled && endpoint != null) {
      _timer = Timer.periodic(flushInterval, (_) => flush());
    }
  }

  /// Initialize OTel tracing. Call once during app startup.
  Future<void> initialize(String serviceName) async {
    if (!enabled || otelEndpoint == null || otelEndpoint!.isEmpty) {
      developer.log(
        'OTel endpoint not configured, tracing disabled',
        name: 'TelemetryService',
      );
      return;
    }

    try {
      // Get the global tracer provider or create one
      final tracerProvider = TracerProviderBase(
        resource: Resource([
          Attribute.fromString(
            ResourceAttributes.serviceName,
            serviceName,
          ),
          Attribute.fromString(
            ResourceAttributes.deploymentEnvironment,
            const String.fromEnvironment('DEPLOYMENT_ENV', defaultValue: 'dev'),
          ),
        ]),
        processors: [
          BatchSpanProcessor(
            CollectorExporter(
              Uri.parse('$otelEndpoint/v1/traces'),
            ),
          ),
        ],
      );

      registerGlobalTracerProvider(tracerProvider);
      _tracer = tracerProvider.getTracer('mycel_mobile');
      _otelInitialized = true;

      developer.log(
        'OTel tracing initialized for $serviceName',
        name: 'TelemetryService',
      );
    } catch (e) {
      developer.log(
        'Failed to initialize OTel: $e',
        name: 'TelemetryService',
        error: e,
      );
    }
  }

  /// Check if OTel is initialized.
  bool get isOtelInitialized => _otelInitialized;

  /// Track a screen view.
  void trackScreen(String screenName, {Map<String, dynamic>? properties}) {
    _track('screen_view', {'screen': screenName, ...?properties});

    // Also record as OTel span
    if (_otelInitialized && _tracer != null) {
      final span = _tracer!.startSpan('screen_view.$screenName');
      properties?.forEach((key, value) {
        span.setAttribute(Attribute.fromString(key, value.toString()));
      });
      span.end();
    }
  }

  /// Track a custom event.
  void trackEvent(String name, {Map<String, dynamic>? properties}) {
    _track(name, properties);

    // Also record as OTel span
    if (_otelInitialized && _tracer != null) {
      final span = _tracer!.startSpan(name);
      properties?.forEach((key, value) {
        span.setAttribute(Attribute.fromString(key, value.toString()));
      });
      span.end();
    }
  }

  /// Track an error with OTel exception recording.
  void trackError(Object error, {StackTrace? stackTrace, String? context}) {
    _track('error', {
      'error': error.toString(),
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
      if (context != null) 'context': context,
    });

    // Record as OTel span with exception
    if (_otelInitialized && _tracer != null) {
      final span = _tracer!.startSpan('exception');
      span.recordException(error, stackTrace: stackTrace ?? StackTrace.current);
      if (context != null) {
        span.setAttribute(Attribute.fromString('error.context', context));
      }
      span.end();
    }
  }

  /// Start a span for manual tracing. Returns a span that must be ended.
  Span? startSpan(String name, {Map<String, dynamic>? attributes}) {
    if (!_otelInitialized || _tracer == null) return null;

    final span = _tracer!.startSpan(name);
    attributes?.forEach((key, value) {
      span.setAttribute(Attribute.fromString(key, value.toString()));
    });
    return span;
  }

  void _track(String name, Map<String, dynamic>? properties) {
    if (!enabled) return;

    _queue.add(TelemetryEvent(
      name: name,
      properties: properties,
      sessionId: _sessionId,
    ));

    developer.log('Telemetry: $name', name: 'TelemetryService');

    if (_queue.length >= batchSize) {
      flush();
    }
  }

  /// Flush pending events to the endpoint.
  Future<void> flush() async {
    if (_queue.isEmpty || endpoint == null) return;

    final batch = List<TelemetryEvent>.from(_queue);
    _queue.clear();

    try {
      await http.post(
        Uri.parse(endpoint!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'events': batch.map((e) => e.toJson()).toList()}),
      );
    } catch (_) {
      // Re-queue on failure
      _queue.insertAll(0, batch);
    }
  }

  /// Flush pending events and release resources.
  void dispose() {
    _timer?.cancel();
    flush();
  }
}
