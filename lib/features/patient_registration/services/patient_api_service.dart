import 'package:image_picker/image_picker.dart';

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
  // POST /api/v1/patients  (multipart/form-data)
  // ---------------------------------------------------------------------------

  /// Registers a new patient using multipart/form-data.
  ///
  /// Both [frontImage] and [sideImage] are mandatory per the backend contract.
  Future<ApiResponse<dynamic>> registerPatient({
    required PatientRegistrationRequest request,
    required XFile frontImage,
    required XFile sideImage,
  }) async {
    AppLogger.info('PatientApiService', 'registerPatient (multipart) called');

    // Build text form fields
    final fields = <String, String>{};
    void addField(String key, String? value) {
      if (value != null && value.isNotEmpty) fields[key] = value;
    }

    addField('reporter_name', request.reporterName);
    addField('reporter_mobile', request.reporterMobile);
    addField('animal_name', request.animalName);
    addField('animal_address', request.animalAddress);
    addField('landmark', request.landmark);
    addField('animal_type', request.animalType);
    addField('color', request.color);
    addField('gender', request.gender);
    addField('age', request.age);
    addField('transported_by', request.transportedBy);
    addField('transporter_contact', request.transporterContact);
    addField('cage_number', request.cageNumber);
    addField('symptoms', request.symptoms);
    addField('tests', request.tests);
    addField('diagnosis', request.diagnosis);
    addField('condition', request.condition);

    if (request.weight != null) {
      fields['weight'] = request.weight.toString();
    }
    if (request.temperature != null) {
      fields['temperature'] = request.temperature.toString();
    }
    // is_sterilized must always be sent as a string
    fields['is_sterilized'] = (request.isSterilized ?? false) ? 'true' : 'false';

    // ─── DEBUG: Print everything being sent ───────────────────────────────────
    final frontBytes = await frontImage.length();
    final sideBytes  = await sideImage.length();

    print('');
    print('╔══════════════════════════════════════════════════════════╗');
    print('║       PATIENT REGISTRATION — MULTIPART REQUEST           ║');
    print('╚══════════════════════════════════════════════════════════╝');
    print('📋 TEXT FIELDS (${fields.length} total):');
    fields.forEach((k, v) => print('   $k = $v'));
    print('📸 FILES:');
    print('   front_image → ${frontImage.path}');
    print('   front_image size → ${(frontBytes / 1024).toStringAsFixed(1)} KB');
    print('   side_image  → ${sideImage.path}');
    print('   side_image size  → ${(sideBytes / 1024).toStringAsFixed(1)} KB');
    print('──────────────────────────────────────────────────────────');
    // ─────────────────────────────────────────────────────────────────────────

    ApiResponse<dynamic> response;
    try {
      response = await _client.postMultipart(
        ApiEndpoints.patients,
        fields: fields,
        files: [
          MultipartFileInput(field: 'front_image', path: frontImage.path),
          MultipartFileInput(field: 'side_image', path: sideImage.path),
        ],
      );
    } catch (e) {
      // ─── DEBUG: print error ───────────────────────────────────────────────
      print('❌ MULTIPART REQUEST FAILED');
      print('   Error type: ${e.runtimeType}');
      print('   Error: $e');
      print('══════════════════════════════════════════════════════════');
      rethrow;
    }

    // ─── DEBUG: Print what the backend returned ───────────────────────────────
    print('✅ BACKEND RESPONSE:');
    print('   success: ${response.success}');
    print('   statusCode: ${response.statusCode}');
    print('   errorMessage: ${response.errorMessage}');
    print('   data: ${response.data}');
    print('══════════════════════════════════════════════════════════');
    print('');

    return response;
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
