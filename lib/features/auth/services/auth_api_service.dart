import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/services/auth_storage_service.dart';

/// API service for internal authentication endpoints.
///
/// All methods use [ApiClient] which automatically prepends
/// the base URL (`http://192.168.1.35:8080/api/v1`).
class AuthApiService {
  final ApiClient _client = ApiClient();
  final AuthStorageService _authStorage = AuthStorageService();

  /// Login an internal user.
  /// `POST /api/v1/auth/login`
  ///
  /// Returns the auth response with access + refresh tokens.
  Future<ApiResponse<dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.authLogin,
      body: {'email': email, 'password': password},
    );

    // Auto-store tokens on successful login.
    if (response.success && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      String? parsedUserId;
      if (data['user_id'] != null) {
        parsedUserId = data['user_id'].toString();
      } else if (data['user'] is String) {
        parsedUserId = data['user'];
      } else if (data['user'] is Map) {
        parsedUserId = data['user']['id']?.toString();
      }

      _authStorage.saveTokens(
        accessToken: data['access_token'] ?? '',
        refreshToken: data['refresh_token'] ?? '',
        userId: parsedUserId,
      );
    }

    return response;
  }

  /// Register a new internal user.
  /// `POST /api/v1/auth/register`
  Future<ApiResponse<dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) {
    return _client.post(
      ApiEndpoints.authRegister,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        ?'phone': phone,
      },
    );
  }

  /// Refresh the access token.
  /// `POST /api/v1/auth/refresh`
  Future<ApiResponse<dynamic>> refreshToken() async {
    final currentRefreshToken = _authStorage.refreshToken;
    if (currentRefreshToken == null) {
      return ApiResponse.error('No refresh token available', statusCode: 401);
    }

    final response = await _client.post(
      ApiEndpoints.authRefresh,
      body: {'refresh_token': currentRefreshToken},
    );

    // Auto-update tokens on success.
    if (response.success && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      _authStorage.saveTokens(
        accessToken: data['access_token'] ?? '',
        refreshToken: data['refresh_token'] ?? currentRefreshToken,
      );
    }

    return response;
  }

  /// Get the current user's profile.
  /// `GET /api/v1/auth/me`
  Future<ApiResponse<dynamic>> getProfile() {
    final userId = _authStorage.userId ?? '';
    return _client.get(
      ApiEndpoints.authMe,
      extraHeaders: {'X-User-ID': userId},
    );
  }

  /// Logout — clears stored tokens.
  void logout() {
    _authStorage.clear();
  }
}
