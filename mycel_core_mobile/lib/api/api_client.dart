import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_state.dart';
import 'interceptor.dart';

/// HTTP client with automatic auth token injection and interceptor chain.
///
/// Constructed by the shell. Modules access via `context.read<ApiClient>()`.
class ApiClient {
  final String baseUrl;
  final AuthState _authState;
  final http.Client _inner;
  final List<ApiInterceptor> _interceptors = [];

  ApiClient({
    required this.baseUrl,
    required AuthState authState,
  })  : _authState = authState,
        _inner = http.Client();

  /// Add an interceptor. Interceptors are sorted by priority.
  void addInterceptor(ApiInterceptor interceptor) {
    _interceptors.add(interceptor);
    _interceptors.sort((a, b) => a.priority.compareTo(b.priority));
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authState.token}',
      };

  /// GET request.
  Future<http.Response> get(String path) => _execute('GET', path);

  /// POST request with JSON body.
  Future<http.Response> post(String path, {Object? body}) =>
      _execute('POST', path, body: body);

  /// PUT request with JSON body.
  Future<http.Response> put(String path, {Object? body}) =>
      _execute('PUT', path, body: body);

  /// PATCH request with JSON body.
  Future<http.Response> patch(String path, {Object? body}) =>
      _execute('PATCH', path, body: body);

  /// DELETE request.
  Future<http.Response> delete(String path) => _execute('DELETE', path);

  Future<http.Response> _execute(String method, String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    var request = http.Request(method, uri);
    request.headers.addAll(_headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    // Run request interceptors (low priority first)
    http.BaseRequest processed = request;
    for (final interceptor in _interceptors) {
      processed = await interceptor.onRequest(processed);
    }

    try {
      final streamed = await _inner.send(processed);
      var response = await http.Response.fromStream(streamed);

      // Run response interceptors (high priority first — reverse onion)
      // Response interceptors receive StreamedResponse, but for simplicity
      // we only apply request/error interceptors in this implementation.

      return response;
    } catch (error) {
      for (final interceptor in _interceptors) {
        await interceptor.onError(error, processed);
      }
      rethrow;
    }
  }

  /// Close the underlying HTTP client.
  void dispose() {
    _inner.close();
  }
}
