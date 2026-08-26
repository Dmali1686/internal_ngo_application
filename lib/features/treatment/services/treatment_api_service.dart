import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// API service for treatment-related endpoints.
///
/// All methods use [ApiClient] which automatically prepends
/// the base URL (`http://192.168.1.35:8080/api/v1`).
class TreatmentApiService {
  final ApiClient _client = ApiClient();

  /// List all treatments for a specific patient.
  /// `GET /api/v1/patients/{id}/treatments`
  Future<ApiResponse<dynamic>> listPatientTreatments(String patientId) {
    return _client.get(ApiEndpoints.patientTreatments(patientId));
  }

  /// Assign a treatment to a medical record.
  /// `POST /api/v1/medical-records/{id}/treatments`
  Future<ApiResponse<dynamic>> assignTreatment({
    required String medicalRecordId,
    required Map<String, dynamic> treatmentData,
  }) {
    return _client.post(
      ApiEndpoints.assignTreatment(medicalRecordId),
      body: treatmentData,
    );
  }

  /// List treatment tasks with optional filters.
  /// `GET /api/v1/treatment-tasks`
  Future<ApiResponse<dynamic>> listTreatmentTasks({
    String? status,
    String? date,
    String? assignedTo,
  }) {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (date != null) queryParams['date'] = date;
    if (assignedTo != null) queryParams['assigned_to'] = assignedTo;

    return _client.get(
      ApiEndpoints.treatmentTasks,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Update a treatment task (e.g., mark as completed).
  /// `PATCH /api/v1/treatment-tasks/{id}`
  Future<ApiResponse<dynamic>> updateTreatmentTask({
    required String taskId,
    required Map<String, dynamic> updates,
  }) {
    return _client.patch(
      ApiEndpoints.updateTreatmentTask(taskId),
      body: updates,
    );
  }
}
