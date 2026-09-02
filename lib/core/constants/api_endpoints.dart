/// All API endpoint paths derived from the Swagger spec.
///
/// Organized by Swagger tags/sections. Every endpoint is relative
/// to [ApiConfig.apiPrefix] (`/api/v1`) — the [ApiClient] prepends
/// the full base URL automatically.
class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Internal Auth
  // ---------------------------------------------------------------------------
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';

  /// GET — list of dashboard modules allowed for the current user's role.
  static const String myModules = '/auth/me/modules';

  // ---------------------------------------------------------------------------
  // Organization — Super Admin only
  // ---------------------------------------------------------------------------

  /// GET — list all departments.
  static const String departments = '/departments';

  /// GET — list all positions (filter by dept via query param).
  static const String positions = '/positions';

  /// GET — list all access categories.
  static const String accessCategories = '/access-categories';

  // ---------------------------------------------------------------------------
  // Users — Super Admin only
  // ---------------------------------------------------------------------------

  /// POST — create a new user profile.
  static const String createUser = '/users';

  /// POST — add assignments (department/position/role) to a user.
  static String userAssignments(String id) => '/users/$id/assignments';

  // ---------------------------------------------------------------------------
  // Admin — Super Admin only
  // ---------------------------------------------------------------------------

  /// GET — list all employees (optionally filtered by role query param).
  static const String employees = '/employees';

  /// PATCH — assign / update a role for a specific employee.
  static String employeeRole(String id) => '/employees/$id/role';

  /// GET — operational analytics (tasks, employee performance, role split).
  static const String adminAnalytics = '/admin/analytics';

  // ---------------------------------------------------------------------------
  // Public Auth
  // ---------------------------------------------------------------------------
  static const String publicAuthLogin = '/public/auth/login';
  static const String publicAuthRegister = '/public/auth/register';
  static const String publicAuthRefresh = '/public/auth/refresh';

  // ---------------------------------------------------------------------------
  // Patients
  // ---------------------------------------------------------------------------
  static const String patients = '/patients';
  static const String patientsStatsAdmissionsToday =
      '/patients/stats/admissions-today';
  static const String patientsStatsEmergencyToday =
      '/patients/stats/emergency-today';

  /// GET / PATCH — requires `{id}` substitution.
  static String patientDetail(String id) => '/patients/$id';

  /// GET — patient by generated Case ID (e.g. MH14-2026-000001).
  static String patientByCaseId(String caseId) => '/patients/case/$caseId';

  /// POST — cage allocation for a patient.
  static String patientCageAllocation(String id) =>
      '/patients/$id/cage-allocation';

  /// GET — QR code for a patient.
  static String patientQrCode(String id) => '/patients/$id/qr-code';

  /// POST — release a patient.
  static String patientRelease(String id) => '/patients/$id/release';

  // ---------------------------------------------------------------------------
  // Medical Records
  // ---------------------------------------------------------------------------

  /// GET / POST — medical records for a patient.
  static String patientMedicalRecords(String patientId) =>
      '/patients/$patientId/medical-records';

  /// GET — single medical record detail.
  static String medicalRecordDetail(String id) => '/medical-records/$id';

  // ---------------------------------------------------------------------------
  // Treatments
  // ---------------------------------------------------------------------------

  /// GET — treatments for a patient.
  static String patientTreatments(String patientId) =>
      '/patients/$patientId/treatments';

  /// POST — assign treatment to a medical record.
  static String assignTreatment(String medicalRecordId) =>
      '/medical-records/$medicalRecordId/treatments';

  /// GET — list treatment tasks (with optional query params).
  static const String treatmentTasks = '/treatment-tasks';

  /// PATCH — update a treatment task.
  static String updateTreatmentTask(String id) => '/treatment-tasks/$id';

  // ---------------------------------------------------------------------------
  // Diet Management
  // ---------------------------------------------------------------------------

  /// GET — full diet history for a patient (DEFAULT + ADDITIONAL).
  static String patientDietHistory(String patientId) =>
      '/patients/$patientId/diet/history';

  /// POST — add an additional diet to a patient without replacing existing.
  static String patientDietAdditional(String patientId) =>
      '/patients/$patientId/diet/additional';

  /// GET / POST — admin: view and create default diet plan rules.
  static const String defaultDietPlans = '/diet/default-plans';

  // ---------------------------------------------------------------------------
  // Medicines
  // ---------------------------------------------------------------------------

  /// GET — paginated medicine master list (supports ?search=, ?page=, ?limit=).
  static const String medicines = '/medicines';

  /// GET — single medicine by ID.
  static String medicineById(String id) => '/medicines/$id';

  // ---------------------------------------------------------------------------
  // Master Data
  // ---------------------------------------------------------------------------
  static const String masterAmbulances = '/master/ambulances';
  static const String masterAnimalTypes = '/master/animal-types';
  static const String masterBreeds = '/master/breeds';
  static const String masterCages = '/master/cages';
  static const String masterColors = '/master/colors';
  static const String masterDietRules = '/master/diet-rules';
  static const String masterMedicines = '/master/medicines';
  static const String masterTreatmentRules = '/master/treatment-rules';

  // ---------------------------------------------------------------------------
  // Media
  // ---------------------------------------------------------------------------
  static const String mediaUpload = '/media/upload';

  // ---------------------------------------------------------------------------
  // Campaigns
  // ---------------------------------------------------------------------------
  static const String campaigns = '/campaigns';

  static String campaignDetail(String id) => '/campaigns/$id';

  static String campaignDonations(String id) => '/campaigns/$id/donations';

  // ---------------------------------------------------------------------------
  // Posts
  // ---------------------------------------------------------------------------
  static const String posts = '/posts';

  static String updatePost(String id) => '/posts/$id';

  static String publishPost(String id) => '/posts/$id/publish';

  // ---------------------------------------------------------------------------
  // Rescue Reports (Internal)
  // ---------------------------------------------------------------------------
  static const String rescueReports = '/rescue-reports';

  static String rescueReportDetail(String id) => '/rescue-reports/$id';

  // ---------------------------------------------------------------------------
  // Rescue Trips (Internal)
  // ---------------------------------------------------------------------------
  static const String rescueTrips = '/rescue-trips';

  static String rescueTripDetail(String id) => '/rescue-trips/$id';

  // ---------------------------------------------------------------------------
  // Public Endpoints
  // ---------------------------------------------------------------------------
  static const String publicCampaigns = '/public/campaigns';

  static String publicCampaignDetail(String id) => '/public/campaigns/$id';

  static const String publicPosts = '/public/posts';

  static const String publicDonations = '/public/donations';

  static const String publicRescueReports = '/public/rescue-reports';

  static String publicRescueReportStatus(String id) =>
      '/public/rescue-reports/$id/status';
}
