import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// API service for diet management endpoints.
///
/// All methods use [ApiClient] which automatically prepends
/// the base URL (`http://192.168.1.35:8080/api/v1`).
class DietApiService {
  final ApiClient _client = ApiClient();

  /// List all diets assigned to a patient.
  /// `GET /api/v1/patients/{id}/diets`
  Future<ApiResponse<dynamic>> listPatientDiets(String patientId) {
    return _client.get(ApiEndpoints.patientDiets(patientId));
  }

  /// Assign a diet to a patient based on a diet rule.
  /// `POST /api/v1/patients/{id}/diets`
  Future<ApiResponse<dynamic>> assignDiet({
    required String patientId,
    required Map<String, dynamic> dietData,
  }) {
    return _client.post(ApiEndpoints.patientDiets(patientId), body: dietData);
  }

  /// Update a diet's status or instructions.
  /// `PATCH /api/v1/patients/{id}/diets/{diet_id}`
  Future<ApiResponse<dynamic>> updateDiet({
    required String patientId,
    required String dietId,
    required Map<String, dynamic> updates,
  }) {
    return _client.patch(
      ApiEndpoints.updateDiet(patientId, dietId),
      body: updates,
    );
  }
}
