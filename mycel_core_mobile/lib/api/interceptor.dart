import 'package:http/http.dart' as http;

/// Base class for API interceptors.
///
/// Interceptors are executed in priority order (lower = earlier on request,
/// later on response — onion model).
///
/// ```dart
/// class AuthInterceptor extends ApiInterceptor {
///   @override
///   int get priority => 0;
///
///   @override
///   Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
///     request.headers['Authorization'] = 'Bearer $token';
///     return request;
///   }
/// }
/// ```
abstract class ApiInterceptor {
  /// Lower values run first on request, last on response.
  int get priority => 0;

  /// Called before the request is sent. Return the (possibly modified) request.
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async => request;

  /// Called after a successful response. Return the (possibly modified) response.
  Future<http.StreamedResponse> onResponse(
    http.StreamedResponse response,
    http.BaseRequest request,
  ) async => response;

  /// Called when the request fails with an exception.
  Future<void> onError(Object error, http.BaseRequest request) async {}
}
