import 'package:http/http.dart' as http;

import '../interceptor.dart';

/// Enforces a timeout on requests by attaching metadata.
///
/// The actual timeout enforcement happens in [ApiClient] via
/// `http.Client.send()` timeout parameter. This interceptor
/// stores the desired timeout in request headers as metadata.
class TimeoutInterceptor extends ApiInterceptor {
  final Duration defaultTimeout;

  TimeoutInterceptor({this.defaultTimeout = const Duration(seconds: 30)});

  @override
  int get priority => 10;

  @override
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    // Store timeout hint in a custom header for ApiClient to read
    request.headers['X-Mycel-Timeout'] = defaultTimeout.inMilliseconds.toString();
    return request;
  }
}
