/// A generic wrapper for API responses.
///
/// Provides a consistent interface for all API calls with
/// [success] status, typed [data], and optional [errorMessage].
class ApiResponse<T> {
  /// Whether the request was successful (2xx status code).
  final bool success;

  /// The parsed response data. `null` when [success] is `false`.
  final T? data;

  /// A human-readable error message. `null` when [success] is `true`.
  final String? errorMessage;

  /// The raw HTTP status code.
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  /// Factory for a successful response.
  factory ApiResponse.ok(T data, {int statusCode = 200}) {
    return ApiResponse(success: true, data: data, statusCode: statusCode);
  }

  /// Factory for a failed response.
  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, statusCode: $statusCode, '
      'error: $errorMessage, data: $data)';
}
