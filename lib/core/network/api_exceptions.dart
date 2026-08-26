/// Custom exceptions thrown by the API layer.
///
/// All exceptions extend [ApiException] so callers can catch
/// a single base type or handle specific sub-types.
library;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown when the server responds with 401 Unauthorized.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Unauthorized'])
    : super(statusCode: 401);
}

/// Thrown when the server responds with 403 Forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Forbidden'])
    : super(statusCode: 403);
}

/// Thrown when the server responds with 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Resource not found'])
    : super(statusCode: 404);
}

/// Thrown when the server responds with 400 Bad Request.
class BadRequestException extends ApiException {
  const BadRequestException([super.message = 'Bad request'])
    : super(statusCode: 400);
}

/// Thrown when the server responds with 500 Internal Server Error.
class ServerException extends ApiException {
  const ServerException([super.message = 'Internal server error'])
    : super(statusCode: 500);
}

/// Thrown when there is no network connectivity.
class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Network error. Check your connection.',
  ]) : super(statusCode: null);
}

/// Thrown when the request times out.
class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Request timed out'])
    : super(statusCode: null);
}
