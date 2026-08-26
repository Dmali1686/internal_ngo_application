import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/logger.dart';
import '../models/patient_registration_model.dart';

/// API service for patient management endpoints.
///
/// All methods use [ApiClient] which automatically prepends
/// the base URL (`http://192.168.1.35:8080/api/v1`).
class PatientApiService {
  final ApiClient _client = ApiClient();

  /// List all patients, optionally filtered by status.
  /// `GET /api/v1/patients`
  Future<ApiResponse<dynamic>> listPatients({String? status}) {
    return _client.get(
      ApiEndpoints.patients,
      queryParameters: status != null ? {'status': status} : null,
    );
  }

  /// Get today's admissions count
  /// `GET /api/v1/patients/stats/admissions-today`
  Future<ApiResponse<dynamic>> getAdmissionsToday() {
    return _client.get(ApiEndpoints.patientsStatsAdmissionsToday);
  }

  /// Get today's emergency cases count
  /// `GET /api/v1/patients/stats/emergency-today`
  Future<ApiResponse<dynamic>> getEmergencyToday() {
    return _client.get(ApiEndpoints.patientsStatsEmergencyToday);
  }

  /// Register a new patient.
  /// `POST /api/v1/patients`
  Future<ApiResponse<dynamic>> registerPatient({
    required PatientRegistrationRequest request,
  }) {
    AppLogger.info('PatientApiService', 'registerPatient called');
    print('========== RESCUE REGISTRATION API REQUEST ==========');
    print(request.toJson());
    print('=====================================================');

    return _client.post(ApiEndpoints.patients, body: request.toJson());
  }

  /// Get comprehensive details of a single patient.
  /// `GET /api/v1/patients/{id}`
  Future<ApiResponse<dynamic>> getPatientDetail(String patientId) {
    return _client.get(ApiEndpoints.patientDetail(patientId));
  }

  /// Update non-critical patient details.
  /// `PATCH /api/v1/patients/{id}`
  Future<ApiResponse<dynamic>> updatePatient({
    required String patientId,
    required Map<String, dynamic> updates,
  }) {
    return _client.patch(ApiEndpoints.patientDetail(patientId), body: updates);
  }

  /// Allocate a cage to a patient.
  /// `POST /api/v1/patients/{id}/cage-allocation`
  Future<ApiResponse<dynamic>> allocateCage({
    required String patientId,
    required String cageId,
  }) {
    return _client.post(
      ApiEndpoints.patientCageAllocation(patientId),
      body: {'cage_id': cageId},
    );
  }

  /// Get the QR code for a patient.
  /// `GET /api/v1/patients/{id}/qr-code`
  Future<ApiResponse<dynamic>> getQrCode(String patientId) {
    return _client.get(ApiEndpoints.patientQrCode(patientId));
  }

  /// Release a patient, freeing their cage.
  /// `POST /api/v1/patients/{id}/release`
  Future<ApiResponse<dynamic>> releasePatient({
    required String patientId,
    required Map<String, dynamic> releaseData,
  }) {
    return _client.post(
      ApiEndpoints.patientRelease(patientId),
      body: releaseData,
    );
  }

  // ---------------------------------------------------------------------------
  // Medical Records
  // ---------------------------------------------------------------------------

  /// List all medical records for a patient.
  /// `GET /api/v1/patients/{id}/medical-records`
  Future<ApiResponse<dynamic>> listMedicalRecords(String patientId) {
    return _client.get(ApiEndpoints.patientMedicalRecords(patientId));
  }

  /// Create a new medical record for a patient.
  /// `POST /api/v1/patients/{id}/medical-records`
  Future<ApiResponse<dynamic>> createMedicalRecord({
    required String patientId,
    required Map<String, dynamic> recordData,
  }) {
    return _client.post(
      ApiEndpoints.patientMedicalRecords(patientId),
      body: recordData,
    );
  }

  /// Get details of a specific medical record.
  /// `GET /api/v1/medical-records/{id}`
  Future<ApiResponse<dynamic>> getMedicalRecordDetail(String recordId) {
    return _client.get(ApiEndpoints.medicalRecordDetail(recordId));
  }
}
