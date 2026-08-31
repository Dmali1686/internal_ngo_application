import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/logger.dart';
import '../../features/admin/screens/role_management_screen.dart';
import '../../features/admin/screens/admin_analytics_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/patient_registration/screens/registration_dashboard_screen.dart';
import '../../features/patient_registration/screens/new_registration_screen.dart';
import '../../features/patient_registration/screens/reporter_details_screen.dart';
import '../../features/patient_registration/screens/rescue_location_screen.dart';
import '../../features/patient_registration/screens/animal_information_screen.dart';
import '../../features/patient_registration/screens/medical_assessment_screen.dart';
import '../../features/patient_registration/screens/transport_details_screen.dart';
import '../../features/patient_registration/screens/review_registration_screen.dart';
import '../../features/patient_registration/screens/registration_success_screen.dart';
import '../../features/patient_registration/screens/edit_patient_screen.dart';
import '../../features/patient_registration/screens/all_patients_screen.dart';
import '../../features/qr_management/screens/qr_scanner_screen.dart';
import '../../features/qr_management/screens/generate_qr_screen.dart';
import '../../features/qr_management/screens/print_qr_screen.dart';
import '../../features/qr_management/screens/scan_qr_screen.dart';
import '../../features/qr_management/screens/patient_detail_screen.dart';
import '../../features/patient_history/screens/animal_overview_screen.dart';
import '../../features/patient_history/screens/medical_timeline_screen.dart';
import '../../features/patient_history/screens/treatment_history_screen.dart';
import '../../features/patient_history/screens/medicine_history_screen.dart';
import '../../features/patient_history/screens/documents_screen.dart';
import '../../features/treatment/screens/treatment_dashboard_screen.dart';
import '../../features/treatment/screens/diagnosis_screen.dart';
import '../../features/treatment/screens/treatment_plan_screen.dart';
import '../../features/treatment/screens/medicine_schedule_screen.dart';
import '../../features/treatment/screens/treatment_timeline_screen.dart';
import '../../features/treatment/screens/daily_progress_screen.dart';
import '../../features/treatment/screens/recovery_screen.dart';
import '../../features/diet_management/screens/diet_dashboard_screen.dart';
import '../../features/diet_management/screens/assign_diet_screen.dart';
import '../../features/diet_management/screens/diet_details_screen.dart';
import '../../features/diet_management/screens/todays_feeding_screen.dart';
import '../../features/diet_management/screens/diet_history_screen.dart';
import '../../features/ambulance/screens/ambulance_dashboard_screen.dart';
import '../../features/ambulance/screens/emergency_requests_screen.dart';
import '../../features/ambulance/screens/request_details_screen.dart';
import '../../features/ambulance/screens/navigation_screen.dart';
import '../../features/ambulance/screens/pickup_screen.dart';
import '../../features/ambulance/screens/hospital_arrival_screen.dart';
import '../../features/employees/screens/employee_dashboard_screen.dart';
import '../../features/employees/screens/employee_list_screen.dart';
import '../../features/employees/screens/employee_profile_screen.dart';
import '../../features/employees/screens/attendance_screen.dart';
import '../../features/employees/screens/assigned_tasks_screen.dart';
import '../../features/employees/screens/performance_screen.dart';
import '../../features/voice_notes/screens/voice_notes_dashboard_screen.dart';
import '../../features/voice_notes/screens/record_voice_note_screen.dart';
import '../../features/voice_notes/screens/playback_voice_note_screen.dart';
import '../../features/voice_notes/screens/voice_notes_history_screen.dart';
import '../../features/cleaning/screens/cleaning_dashboard_screen.dart';
import '../../features/doctor_panel/screens/doctor_panel_screen.dart';
import '../../features/doctor_panel/screens/doctor_medical_orders_screen.dart';
import '../../features/doctor_panel/screens/doctor_food_schedule_screen.dart';
import '../../features/doctor_panel/screens/doctor_cleaning_schedule_screen.dart';
import '../../features/super_admin/screens/super_admin_dashboard_screen.dart';
import '../../features/super_admin/screens/department_detail_screen.dart';
import '../../features/super_admin/screens/super_admin_employee_profile_screen.dart';
import '../../features/super_admin/models/super_admin_models.dart';
import '../../features/public_posting/screens/compose_public_post_screen.dart';
import '../../features/public_posting/providers/compose_post_provider.dart';
import 'package:provider/provider.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  redirect: (BuildContext context, GoRouterState state) {
    AppLogger.navigation(state.uri.toString());
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/dashboard-transition',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/registration-dashboard',
      builder: (context, state) => const RegistrationDashboardScreen(),
    ),
    GoRoute(
      path: '/new-registration',
      builder: (context, state) => const NewRegistrationScreen(),
    ),
    GoRoute(
      path: '/reporter-details',
      builder: (context, state) => const ReporterDetailsScreen(),
    ),
    GoRoute(
      path: '/rescue-location',
      builder: (context, state) => const RescueLocationScreen(),
    ),
    GoRoute(
      path: '/animal-information',
      builder: (context, state) => const AnimalInformationScreen(),
    ),
    GoRoute(
      path: '/medical-assessment',
      builder: (context, state) => const MedicalAssessmentScreen(),
    ),
    GoRoute(
      path: '/transport-details',
      builder: (context, state) => const TransportDetailsScreen(),
    ),
    GoRoute(
      path: '/review-registration',
      builder: (context, state) => const ReviewRegistrationScreen(),
    ),
    GoRoute(
      path: '/registration-success',
      builder: (context, state) => const RegistrationSuccessScreen(),
    ),
    GoRoute(
      path: '/edit-patient',
      builder: (context, state) {
        final patient = state.extra as Map<String, dynamic>;
        return EditPatientScreen(patient: patient);
      },
    ),
    GoRoute(
      path: '/all-patients',
      builder: (context, state) => const AllPatientsScreen(),
    ),
    GoRoute(
      path: '/qr-scanner',
      builder: (context, state) => const QrScannerScreen(),
    ),
    GoRoute(
      path: '/generate-qr',
      builder: (context, state) => const GenerateQrScreen(),
    ),
    GoRoute(
      path: '/print-qr',
      builder: (context, state) => const PrintQrScreen(),
    ),
    GoRoute(
      path: '/scan-qr',
      builder: (context, state) => const ScanQrScreen(),
    ),
    GoRoute(
      path: '/patient-detail',
      builder: (context, state) {
        final patient = state.extra as Map<String, dynamic>? ?? {};
        return PatientDetailScreen(patient: patient);
      },
    ),
    GoRoute(
      path: '/animal-overview',
      builder: (context, state) => const AnimalOverviewScreen(),
    ),
    GoRoute(
      path: '/medical-timeline',
      builder: (context, state) => const MedicalTimelineScreen(),
    ),
    GoRoute(
      path: '/treatment-history',
      builder: (context, state) => const TreatmentHistoryScreen(),
    ),

    GoRoute(
      path: '/medicine-history',
      builder: (context, state) => const MedicineHistoryScreen(),
    ),
    GoRoute(
      path: '/documents',
      builder: (context, state) => const DocumentsScreen(),
    ),
    GoRoute(
      path: '/treatment-dashboard',
      builder: (context, state) => const TreatmentDashboardScreen(),
    ),
    GoRoute(
      path: '/diagnosis',
      builder: (context, state) => const DiagnosisScreen(),
    ),
    GoRoute(
      path: '/treatment-plan',
      builder: (context, state) => const TreatmentPlanScreen(),
    ),
    GoRoute(
      path: '/medicine-schedule',
      builder: (context, state) => const MedicineScheduleScreen(),
    ),
    GoRoute(
      path: '/treatment-timeline',
      builder: (context, state) => const TreatmentTimelineScreen(),
    ),
    GoRoute(
      path: '/daily-progress',
      builder: (context, state) => const DailyProgressScreen(),
    ),
    GoRoute(
      path: '/recovery',
      builder: (context, state) => const RecoveryScreen(),
    ),
    GoRoute(
      path: '/diet-dashboard',
      builder: (context, state) => const DietDashboardScreen(),
    ),
    GoRoute(
      path: '/assign-diet',
      builder: (context, state) => const AssignDietScreen(),
    ),
    GoRoute(
      path: '/diet-details',
      builder: (context, state) => const DietDetailsScreen(),
    ),
    GoRoute(
      path: '/todays-feeding',
      builder: (context, state) => const TodaysFeedingScreen(),
    ),
    GoRoute(
      path: '/diet-history',
      builder: (context, state) => const DietHistoryScreen(),
    ),
    GoRoute(
      path: '/cleaning-dashboard',
      builder: (context, state) => const CleaningDashboardScreen(),
    ),
    GoRoute(
      path: '/doctor-panel',
      builder: (context, state) => const DoctorPanelScreen(),
    ),
    GoRoute(
      path: '/doctor-medical-orders',
      builder: (context, state) => const DoctorMedicalOrdersScreen(),
    ),
    GoRoute(
      path: '/doctor-food-schedule',
      builder: (context, state) => const DoctorFoodScheduleScreen(),
    ),
    GoRoute(
      path: '/doctor-cleaning-schedule',
      builder: (context, state) => const DoctorCleaningScheduleScreen(),
    ),
    GoRoute(
      path: '/ambulance-dashboard',
      builder: (context, state) => const AmbulanceDashboardScreen(),
    ),
    GoRoute(
      path: '/emergency-requests',
      builder: (context, state) => const EmergencyRequestsScreen(),
    ),
    GoRoute(
      path: '/request-details',
      builder: (context, state) => const RequestDetailsScreen(),
    ),
    GoRoute(
      path: '/navigation',
      builder: (context, state) => const NavigationScreen(),
    ),
    GoRoute(path: '/pickup', builder: (context, state) => const PickupScreen()),
    GoRoute(
      path: '/hospital-arrival',
      builder: (context, state) => const HospitalArrivalScreen(),
    ),
    GoRoute(
      path: '/employee-dashboard',
      builder: (context, state) => const EmployeeDashboardScreen(),
    ),
    GoRoute(
      path: '/employee-list',
      builder: (context, state) => const EmployeeListScreen(),
    ),
    GoRoute(
      path: '/employee-profile',
      builder: (context, state) => const EmployeeProfileScreen(),
    ),
    GoRoute(
      path: '/attendance',
      builder: (context, state) => const AttendanceScreen(),
    ),
    GoRoute(
      path: '/assigned-tasks',
      builder: (context, state) => const AssignedTasksScreen(),
    ),
    GoRoute(
      path: '/performance',
      builder: (context, state) => const PerformanceScreen(),
    ),
    GoRoute(
      path: '/voice-notes-dashboard',
      builder: (context, state) => const VoiceNotesDashboardScreen(),
    ),
    GoRoute(
      path: '/record-voice-note',
      builder: (context, state) => const RecordVoiceNoteScreen(),
    ),
    GoRoute(
      path: '/playback-voice-note',
      builder: (context, state) => const PlaybackVoiceNoteScreen(),
    ),
    GoRoute(
      path: '/voice-notes-history',
      builder: (context, state) => const VoiceNotesHistoryScreen(),
    ),
    // ── Super Admin routes ────────────────────────────────────────────────────
    GoRoute(
      path: '/role-management',
      builder: (context, state) => const RoleManagementScreen(),
    ),
    GoRoute(
      path: '/admin-analytics',
      builder: (context, state) => const AdminAnalyticsScreen(),
    ),
    GoRoute(
      path: '/super-admin-dashboard',
      builder: (context, state) => const SuperAdminDashboardScreen(),
    ),
    GoRoute(
      path: '/department-detail',
      builder: (context, state) {
        final dept = state.extra as DepartmentModel;
        return DepartmentDetailScreen(department: dept);
      },
    ),
    GoRoute(
      path: '/super-admin-employee-profile',
      builder: (context, state) {
        final employee = state.extra as DepartmentEmployeeModel;
        return SuperAdminEmployeeProfileScreen(employee: employee);
      },
    ),
    // ── Public Posting routes ───────────────────────────────────────────────
    GoRoute(
      path: '/share-to-public',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => ComposePostProvider(),
          child: const ComposePublicPostScreen(),
        );
      },
    ),
  ],
);
