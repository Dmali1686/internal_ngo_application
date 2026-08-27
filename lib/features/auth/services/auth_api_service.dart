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

  /// Login an internal user based on role.
  Future<ApiResponse<dynamic>> login({
    required String identifier, // username or email_or_mobile
    required String password,
    required String role, // 'Employee', 'Admin', 'Super Admin'
  }) async {
    String endpoint;
    Map<String, dynamic> body = {'password': password};

    if (role == 'Employee') {
      endpoint = ApiEndpoints.authEmployeeLogin;
      body['username'] = identifier;
    } else if (role == 'Admin') {
      // Assuming Admin uses a similar endpoint to Super Admin or has its own. 
      // Falling back to employee login structure or super admin based on standard.
      // We will map it to authAdminLogin if it exists, otherwise employee.
      endpoint = ApiEndpoints.authAdminLogin;
      body['username'] = identifier; // Adjust if backend expects email_or_mobile for Admin
    } else {
      // Super Admin
      endpoint = ApiEndpoints.authSuperAdminLogin;
      body['email_or_mobile'] = identifier;
    }

    final response = await _client.post(
      endpoint,
      body: body,
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
        if (phone != null) 'phone': phone,
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
