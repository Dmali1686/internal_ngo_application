/// Central API configuration for the Animal Welfare backend.
///
/// All API calls throughout the app should use these constants
/// instead of hardcoding URLs directly.
class ApiConfig {
  ApiConfig._();

  /// The base URL of the backend server.
  /// Change this value when switching between environments.
  static const String baseUrl = 'http://3.111.39.189';
  // static const String baseUrl = 'http://192.168.31.162:8081';
// static const String baseUrl = 'http://10.139.20.133:8081';

  

  

  /// The API version prefix applied to all endpoints.
  static const String apiPrefix = '/api/v1';

  /// Full base URL with API prefix for convenience.
  static String get fullBaseUrl => '$baseUrl$apiPrefix';

  /// Default request timeout in seconds.
  static const int connectTimeoutSeconds = 30;

  /// Default response timeout in seconds.
  static const int receiveTimeoutSeconds = 30;

  /// Default headers applied to every request.
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
