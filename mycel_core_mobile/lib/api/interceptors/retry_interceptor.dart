import 'package:http/http.dart' as http;

import '../interceptor.dart';

/// Retries failed requests with exponential backoff.
class RetryInterceptor extends ApiInterceptor {
  final int maxRetries;
  final Duration backoff;

  int _retryCount = 0;

  RetryInterceptor({this.maxRetries = 2, this.backoff = const Duration(milliseconds: 500)});

  @override
  int get priority => 100;

  @override
  Future<void> onError(Object error, http.BaseRequest request) async {
    if (_retryCount >= maxRetries) {
      _retryCount = 0;
      return;
    }
    _retryCount++;
    await Future.delayed(backoff * (1 << (_retryCount - 1)));
  }
}
