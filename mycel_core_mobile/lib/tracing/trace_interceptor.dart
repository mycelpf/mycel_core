import 'package:http/http.dart' as http;

import '../api/interceptor.dart';
import 'tracer.dart';

/// ApiInterceptor that injects W3C `traceparent` header.
class TraceInterceptor extends ApiInterceptor {
  final Tracer tracer;

  TraceInterceptor(this.tracer);

  @override
  int get priority => 1;

  @override
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    final span = tracer.startSpan('${request.method} ${request.url}');
    request.headers['traceparent'] = span.traceparent;
    return request;
  }
}
