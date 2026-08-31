import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/logger.dart';
import '../models/create_user_request.dart';
import '../models/user_assignment_request.dart';
import '../models/department_model.dart';
import '../models/position_model.dart';
import '../models/access_category_model.dart';
import '../models/user_model.dart';


/// Service for Super Admin user-management APIs.
///
/// Endpoints:
///   GET  /api/v1/departments
///   GET  /api/v1/positions
///   POST /api/v1/users
///   POST /api/v1/users/{id}/assignments
class UserApiService {
  final ApiClient _client = ApiClient();

  // ---------------------------------------------------------------------------
  // Organization
  // ---------------------------------------------------------------------------

  /// GET /api/v1/departments
  Future<ApiResponse<List<DepartmentModel>>> getDepartments() async {
    AppLogger.info('UserApiService', 'GET /departments');
    try {
      final response = await _client.get(ApiEndpoints.departments);
      AppLogger.info('UserApiService', 'getDepartments → success: ${response.success}');
      if (response.success && response.data is List) {
        final list = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map(DepartmentModel.fromJson)
            .toList();
        AppLogger.info('UserApiService', 'Loaded ${list.length} departments');
        return ApiResponse.ok(list);
      }
      return ApiResponse.error(response.errorMessage ?? 'Failed to load departments');
    } catch (e) {
      AppLogger.error('UserApiService', 'getDepartments error: $e');
      return ApiResponse.error('Network error: $e');
    }
  }

  /// GET /api/v1/positions
  Future<ApiResponse<List<PositionModel>>> getPositions() async {
    AppLogger.info('UserApiService', 'GET /positions');
    try {
      final response = await _client.get(ApiEndpoints.positions);
      AppLogger.info('UserApiService', 'getPositions → success: ${response.success}');
      if (response.success && response.data is List) {
        final list = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map(PositionModel.fromJson)
            .toList();
        AppLogger.info('UserApiService', 'Loaded ${list.length} positions');
        return ApiResponse.ok(list);
      }
      return ApiResponse.error(response.errorMessage ?? 'Failed to load positions');
    } catch (e) {
      AppLogger.error('UserApiService', 'getPositions error: $e');
      return ApiResponse.error('Network error: $e');
    }
  }

  /// GET /api/v1/access-categories
  Future<ApiResponse<List<AccessCategoryModel>>> getAccessCategories() async {
    AppLogger.info('UserApiService', 'GET /access-categories');
    try {
      final response = await _client.get(ApiEndpoints.accessCategories);
      AppLogger.info('UserApiService', 'getAccessCategories → success: ${response.success}');
      if (response.success && response.data is List) {
        final list = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map(AccessCategoryModel.fromJson)
            .toList();
        AppLogger.info('UserApiService', 'Loaded ${list.length} access categories');
        return ApiResponse.ok(list);
      }
      return ApiResponse.error(response.errorMessage ?? 'Failed to load access categories');
    } catch (e) {
      AppLogger.error('UserApiService', 'getAccessCategories error: $e');
      return ApiResponse.error('Network error: $e');
    }
  }


  // ---------------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------------

  /// POST /api/v1/users — creates user and returns the new user_id.
  Future<ApiResponse<String>> createUser(CreateUserRequest req) async {
    AppLogger.info('UserApiService', 'POST /users → ${req.username}');
    try {
      final response = await _client.post(
        ApiEndpoints.createUser,
        body: req.toJson(),
      );
      AppLogger.info('UserApiService', 'createUser → success: ${response.success}, data: ${response.data}');
      if (response.success && response.data is Map<String, dynamic>) {
        final userId = response.data['user_id'] as String;
        AppLogger.info('UserApiService', 'User created with ID: $userId');
        return ApiResponse.ok(userId, statusCode: 201);
      }
      AppLogger.error('UserApiService', 'createUser failed: ${response.errorMessage}');
      return ApiResponse.error(response.errorMessage ?? 'Failed to create user');
    } catch (e) {
      AppLogger.error('UserApiService', 'createUser exception: $e');
      return ApiResponse.error('Network error: $e');
    }
  }

  /// POST /api/v1/users/{id}/assignments
  Future<ApiResponse<dynamic>> assignUser(
    String userId,
    List<UserAssignmentRequest> assignments,
  ) async {
    AppLogger.info('UserApiService', 'POST /users/$userId/assignments (${assignments.length} roles)');
    try {
      final response = await _client.post(
        ApiEndpoints.userAssignments(userId),
        body: {'assignments': assignments.map((a) => a.toJson()).toList()},
      );
      AppLogger.info('UserApiService', 'assignUser → success: ${response.success}');
      if (!response.success) {
        AppLogger.error('UserApiService', 'assignUser failed: ${response.errorMessage}');
      }
      return response;
    } catch (e) {
      AppLogger.error('UserApiService', 'assignUser exception: $e');
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Combined: POST /users then POST /users/{id}/assignments in one call.
  Future<ApiResponse<Map<String, dynamic>>> createEmployeeWithAssignment({
    required CreateUserRequest user,
    required UserAssignmentRequest assignment,
  }) async {
    AppLogger.action('UserApiService', '=== CREATE EMPLOYEE FLOW ===');

    // Step 1: Create user
    AppLogger.info('UserApiService', 'Step 1: Creating user profile...');
    final createRes = await createUser(user);
    if (!createRes.success) {
      AppLogger.error('UserApiService', 'Step 1 FAILED: ${createRes.errorMessage}');
      return ApiResponse.error(createRes.errorMessage!);
    }

    final userId = createRes.data!;
    AppLogger.info('UserApiService', 'Step 1 OK: user_id = $userId');

    // Step 2: Assign role/dept/position
    AppLogger.info('UserApiService', 'Step 2: Assigning role to user...');
    final assignRes = await assignUser(userId, [assignment]);
    if (!assignRes.success) {
      final errMsg = 'User created (ID: $userId) but assignment failed: ${assignRes.errorMessage}';
      AppLogger.error('UserApiService', 'Step 2 FAILED: $errMsg');
      return ApiResponse.error(errMsg);
    }

    AppLogger.action('UserApiService', '=== EMPLOYEE CREATED SUCCESSFULLY ===');
    return ApiResponse.ok({'user_id': userId, 'message': 'Employee created successfully'});
  }

  /// Fetches all active users — Super Admin only.
  ///
  /// GET /api/v1/users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client.get('/users');
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['users'] ?? []);
        return data
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('UserApiService', 'Failed to get all users: $e');
      rethrow;
    }
  }
}
