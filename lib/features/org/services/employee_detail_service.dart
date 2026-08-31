import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/employee_detail_model.dart';

/// Service for the Department Employee Detail endpoint.
///
/// Endpoint: GET /api/v1/departments/{id}/employees/{user_id}
class EmployeeDetailService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches `GET /departments/{departmentId}/employees/{userId}`.
  ///
  /// Returns an [EmployeeDetailResponse] or throws an [ApiException].
  Future<EmployeeDetailResponse> getEmployeeDetail({
    required String departmentId,
    required String userId,
  }) async {
    AppLogger.info('EmployeeDetailService', 'Fetching /departments/$departmentId/employees/$userId');
    final response = await _apiClient.get(
      '/departments/$departmentId/employees/$userId',
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      AppLogger.info('EmployeeDetailService', 'Parsing successful response');
      return EmployeeDetailResponse.fromJson(data);
    }

    throw Exception(
      'Unexpected response format from /departments/$departmentId/employees/$userId',
    );
  }
}
