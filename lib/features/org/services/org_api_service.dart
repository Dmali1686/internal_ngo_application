import '../../../core/network/api_client.dart';
import '../models/department_org_model.dart';

/// Service layer for the Department Organization endpoint.
///
/// Uses the shared [ApiClient] singleton so auth tokens and
/// base-URL configuration are picked up automatically.
class OrgApiService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches `GET /departments/{id}/organization`.
  ///
  /// Returns a [DepartmentOrganizationResponse] or throws an [ApiException]
  /// if the request fails.
  Future<DepartmentOrganizationResponse> getDepartmentOrganization(
    String departmentId,
  ) async {
    final response = await _apiClient.get(
      '/departments/$departmentId/organization',
    );

    final data = response.data;
    print('--- RAW API RESPONSE FOR DEPARTMENT ORGANIZATION ---');
    print(data);
    print('----------------------------------------------------');
    if (data is Map<String, dynamic>) {
      return DepartmentOrganizationResponse.fromJson(data);
    }

    throw Exception(
      'Unexpected response format from /departments/$departmentId/organization',
    );
  }
}
