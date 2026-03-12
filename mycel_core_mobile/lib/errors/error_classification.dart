/// Categorizes errors for client-side handling.
///
/// Matches the service and web platform enums.
enum ErrorClassification {
  validation,
  authentication,
  authorization,
  notFound,
  conflict,
  rateLimit,
  internal,
  external,
  timeout,
}

/// Maps an HTTP status code to an error classification.
ErrorClassification classifyHttpStatus(int statusCode) {
  switch (statusCode) {
    case 401:
      return ErrorClassification.authentication;
    case 403:
      return ErrorClassification.authorization;
    case 404:
      return ErrorClassification.notFound;
    case 409:
      return ErrorClassification.conflict;
    case 422:
      return ErrorClassification.validation;
    case 429:
      return ErrorClassification.rateLimit;
    default:
      if (statusCode >= 500) return ErrorClassification.internal;
      return ErrorClassification.external;
  }
}
