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
    required String mobile, 
    required String password,
    required String accessId, 
  }) async {
    final response = await _client.post(
      ApiEndpoints.authLogin,
      body: {
        'mobile': mobile,
        'password': password,
        'access_id': accessId,
      },
    );

    // Auto-store tokens on successful login.
    if (response.success && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      String? parsedUserId;
      if (data['user_id'] != null) {
        parsedUserId = data['user_id'].toString();
      } else if (data['user'] is String) {
        parsedUserId = data['user'];
      }

      bool isDoc = false;
      if (data['user'] is Map) {
        final userMap = data['user'] as Map;
        parsedUserId = userMap['id']?.toString();
        final fullName = userMap['full_name']?.toString().toLowerCase() ?? '';
        final empCode = userMap['employee_code']?.toString().toLowerCase() ?? '';
        if (fullName.startsWith('dr.') || fullName.startsWith('dr ') || empCode.contains('doc')) {
          isDoc = true;
        }
      }

      _authStorage.saveTokens(
        accessToken: data['access_token'] ?? '',
        refreshToken: data['refresh_token'] ?? '',
        userId: parsedUserId,
      );
      _authStorage.setIsDoctor(isDoc);
      
      // Fetch profile to get department_id, position title and other details
      try {
        final profileRes = await getProfile();
        if (profileRes.success && profileRes.data is Map) {
          final profileMap = profileRes.data as Map;
          if (profileMap['department_id'] != null) {
            _authStorage.setDepartmentId(profileMap['department_id'].toString());
          }
          // Save the backend position/role title (e.g. 'Medical HOD', 'Veterinarian')
          final backendRole = profileMap['role']?.toString() ??
              profileMap['position_title']?.toString() ??
              profileMap['position']?.toString() ??
              profileMap['access_category']?.toString();
          if (backendRole != null && backendRole.isNotEmpty) {
            _authStorage.setPositionTitle(backendRole);
            // Auto-detect if the user is a doctor/HOD from their backend role
            final roleLower = backendRole.toLowerCase();
            if (!isDoc &&
                (roleLower.contains('doctor') ||
                    roleLower.contains('dr.') ||
                    roleLower.contains('veterinar') ||
                    roleLower.contains('hod') ||
                    roleLower.contains('medical officer') ||
                    roleLower.contains('medical hod'))) {
              isDoc = true;
              _authStorage.setIsDoctor(isDoc);
            }
          }
        }
      } catch (e) {
        print('Failed to fetch profile during login: $e');
      }
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
  Future<ApiResponse<dynamic>> getProfile() async {
    final userId = _authStorage.userId ?? '';
    final response = await _client.get(
      ApiEndpoints.authMe,
      extraHeaders: {'X-User-ID': userId},
    );
    
    if (response.success && response.data is Map) {
      final data = response.data as Map;
      if (data['department_id'] != null) {
        _authStorage.setDepartmentId(data['department_id'].toString());
      }
    }
    
    return response;
  }

  /// Logout — clears stored tokens.
  void logout() {
    _authStorage.clear();
  }
}
