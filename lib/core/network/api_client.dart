import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/logger.dart';
import '../services/auth_storage_service.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

/// A centralized HTTP client that prepends [ApiConfig.baseUrl] and
/// [ApiConfig.apiPrefix] to every request.
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// final response = await client.get(ApiEndpoints.patients);
/// ```
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  final http.Client _httpClient = http.Client();

  // ---------------------------------------------------------------------------
  // Public convenience methods
  // ---------------------------------------------------------------------------

  /// Sends a GET request to `baseUrl + apiPrefix + endpoint`.
  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(endpoint, queryParameters: queryParameters);
    return _send('GET', uri, extraHeaders: extraHeaders);
  }

  /// Sends a POST request with an optional JSON [body].
  Future<ApiResponse<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(endpoint);
    return _send('POST', uri, body: body, extraHeaders: extraHeaders);
  }

  /// Sends a PATCH request with an optional JSON [body].
  Future<ApiResponse<dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(endpoint);
    return _send('PATCH', uri, body: body, extraHeaders: extraHeaders);
  }

  /// Sends a DELETE request.
  Future<ApiResponse<dynamic>> delete(
    String endpoint, {
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(endpoint);
    return _send('DELETE', uri, extraHeaders: extraHeaders);
  }

  /// Uploads a file using multipart/form-data POST.
  Future<ApiResponse<dynamic>> uploadFile(
    String endpoint, {
    required String filePath,
    String fieldName = 'file',
    Map<String, String>? extraFields,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(endpoint);
    AppLogger.info('ApiClient', '📤 UPLOAD $uri');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_mergedHeaders(extraHeaders))
        ..files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      if (extraFields != null) {
        request.fields.addAll(extraFields);
      }

      final streamedResponse = await request.send().timeout(
        Duration(seconds: ApiConfig.receiveTimeoutSeconds),
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Upload failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Builds the full [Uri] for a given endpoint.
  Uri _buildUri(String endpoint, {Map<String, String>? queryParameters}) {
    final path = '${ApiConfig.apiPrefix}$endpoint';
    // Parse the base URL and merge with path + query params.
    final baseUri = Uri.parse(ApiConfig.baseUrl);
    return baseUri.replace(
      path: path,
      queryParameters: (queryParameters != null && queryParameters.isNotEmpty)
          ? queryParameters
          : null,
    );
  }

  /// Merges default headers with auth token and any extra headers.
  Map<String, String> _mergedHeaders(Map<String, String>? extraHeaders) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

    // Attach Bearer token if available.
    final token = AuthStorageService().accessToken;
    if (token != null && token.isNotEmpty) {
      if (token.startsWith('Bearer ')) {
        headers['Authorization'] = token;
      } else {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  /// Sends the HTTP request and processes the response.
  Future<ApiResponse<dynamic>> _send(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    AppLogger.info('ApiClient', '→ $method $uri');
    if (body != null) {
      AppLogger.info('ApiClient', '  Body: ${jsonEncode(body)}');
    }

    try {
      late http.Response response;
      final headers = _mergedHeaders(extraHeaders);
      final encodedBody = body != null ? jsonEncode(body) : null;
      final timeout = Duration(seconds: ApiConfig.receiveTimeoutSeconds);

      switch (method) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: headers)
              .timeout(timeout);
          break;
        case 'POST':
          response = await _httpClient
              .post(uri, headers: headers, body: encodedBody)
              .timeout(timeout);
          break;
        case 'PATCH':
          response = await _httpClient
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(uri, headers: headers)
              .timeout(timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return _processResponse(response);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: $e');
    }
  }

  /// Converts the raw [http.Response] into an [ApiResponse] or throws
  /// a typed [ApiException].
  ApiResponse<dynamic> _processResponse(http.Response response) {
    AppLogger.info(
      'ApiClient',
      '← ${response.statusCode} (${response.body.length} bytes)',
    );

    dynamic decoded;
    try {
      decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      decoded = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.ok(decoded, statusCode: response.statusCode);
    }

    // Extract error message from response body when possible.
    String errorMsg = 'Request failed with status ${response.statusCode}';
    if (decoded is Map<String, dynamic>) {
      errorMsg =
          decoded['error']?.toString() ??
          decoded['message']?.toString() ??
          errorMsg;
    }

    switch (response.statusCode) {
      case 400:
        throw BadRequestException(errorMsg);
      case 401:
        throw UnauthorizedException(errorMsg);
      case 403:
        throw ForbiddenException(errorMsg);
      case 404:
        throw NotFoundException(errorMsg);
      default:
        if (response.statusCode >= 500) {
          throw ServerException(errorMsg);
        }
        throw ApiException(errorMsg, statusCode: response.statusCode);
    }
  }
}
