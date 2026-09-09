import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// API service for Super Admin exclusive endpoints.
///
/// All methods use [ApiClient] which automatically prepends
/// the base URL and `/api/v1` prefix.
class AdminApiService {
  final ApiClient _client = ApiClient();

  // ---------------------------------------------------------------------------
  // Employees
  // ---------------------------------------------------------------------------

  /// List all employees.
  /// `GET /api/v1/employees`
  Future<ApiResponse<dynamic>> listEmployees({String? role}) {
    final params = role != null ? {'role': role} : null;
    return _client.get(ApiEndpoints.employees, queryParameters: params);
  }

  /// Assign or update the role of an employee.
  /// `PATCH /api/v1/employees/{id}/role`
  ///
  /// [roleKey] must be one of [AppRoles.assignable].
  Future<ApiResponse<dynamic>> assignRole({
    required String employeeId,
    required String roleKey,
  }) {
    return _client.patch(
      ApiEndpoints.employeeRole(employeeId),
      body: {'role': roleKey},
    );
  }

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  /// Fetch operational analytics for the Super Admin dashboard.
  /// `GET /api/v1/admin/analytics?period={period}`
  ///
  /// [period] values: `'today'` | `'week'` | `'month'`
  Future<ApiResponse<dynamic>> getAnalytics({String period = 'week'}) {
    return _client.get(
      ApiEndpoints.adminAnalytics,
      queryParameters: {'period': period},
    );
  }
}
