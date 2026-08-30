import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/logger.dart';
import '../models/patient_registration_model.dart';

/// API service for patient management endpoints.
///
/// All methods use [ApiClient] which automatically prepends
/// the base URL and `/api/v1` prefix.
class PatientApiService {
  final ApiClient _client = ApiClient();

  // ---------------------------------------------------------------------------
  // 1. Register a New Patient
  // POST /api/v1/patients
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> registerPatient({
    required PatientRegistrationRequest request,
  }) {
    AppLogger.info('PatientApiService', 'registerPatient called');
    print('========== RESCUE REGISTRATION API REQUEST ==========');
    print(request.toJson());
    print('=====================================================');
    return _client.post(ApiEndpoints.patients, body: request.toJson());
  }

  // ---------------------------------------------------------------------------
  // 2. Get All Patients (paginated + filtered)
  // GET /api/v1/patients
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> listPatients({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? animalType,
    String? gender,
    String? fromDate,
    String? toDate,
  }) {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (animalType != null && animalType.isNotEmpty) params['animal_type'] = animalType;
    if (gender != null && gender.isNotEmpty) params['gender'] = gender;
    if (fromDate != null && fromDate.isNotEmpty) params['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) params['to_date'] = toDate;

    return _client.get(
      ApiEndpoints.patients,
      queryParameters: params.isNotEmpty ? params : null,
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Get Patient By ID (UUID)
  // GET /api/v1/patients/{id}
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> getPatientById(String patientId) {
    return _client.get(ApiEndpoints.patientDetail(patientId));
  }

  // ---------------------------------------------------------------------------
  // 4. Get Patient By Case ID
  // GET /api/v1/patients/case/{case_id}
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> getPatientByCaseId(String caseId) {
    return _client.get(ApiEndpoints.patientByCaseId(caseId));
  }

  // ---------------------------------------------------------------------------
  // 5. Add a Treatment
  // POST /api/v1/patients/{id}/treatments
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> addTreatment({
    required String patientId,
    required AddTreatmentRequest request,
  }) {
    AppLogger.info('PatientApiService', 'addTreatment for patient: $patientId');
    return _client.post(
      ApiEndpoints.patientTreatments(patientId),
      body: request.toJson(),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Get Treatment History
  // GET /api/v1/patients/{id}/treatments
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> getTreatmentHistory(String patientId) {
    return _client.get(ApiEndpoints.patientTreatments(patientId));
  }

  // ---------------------------------------------------------------------------
  // Stats (used by dashboard)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> getAdmissionsToday() {
    return _client.get(ApiEndpoints.patientsStatsAdmissionsToday);
  }

  Future<ApiResponse<dynamic>> getEmergencyToday() {
    return _client.get(ApiEndpoints.patientsStatsEmergencyToday);
  }

  // ---------------------------------------------------------------------------
  // Update patient (PATCH)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> updatePatient({
    required String patientId,
    required Map<String, dynamic> updates,
  }) {
    return _client.patch(ApiEndpoints.patientDetail(patientId), body: updates);
  }
}
