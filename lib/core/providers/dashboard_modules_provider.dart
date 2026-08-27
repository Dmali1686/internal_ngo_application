import 'package:flutter/material.dart';
import '../../core/models/dashboard_module_model.dart';
import '../../core/utils/logger.dart';
import '../../features/home/services/dashboard_modules_api_service.dart';

/// Provider that fetches the role-based dashboard module cards from the backend.
///
/// **Fallback strategy**: if the API call fails for ANY reason (network error,
/// server error, bad JSON, etc.) we automatically fall back to [_allModules]
/// so the user always sees a fully functional dashboard.
///
/// States:
///  - [isLoading] — true while the first API call is in flight
///  - [modules]   — the resolved list (from API or fallback)
///  - [userRole]  — role string returned by the backend ("admin", "doctor", etc.)
///  - [isUsingFallback] — true when we are showing the hardcoded default list
class DashboardModulesProvider extends ChangeNotifier {
  final DashboardModulesApiService _apiService = DashboardModulesApiService();

  bool _isLoading = false;
  bool _isUsingFallback = false;
  String? _userRole;
  List<DashboardModuleModel> _modules = [];

  bool get isLoading => _isLoading;
  bool get isUsingFallback => _isUsingFallback;
  String? get userRole => _userRole;
  List<DashboardModuleModel> get modules =>
      _modules.isEmpty ? _allModules : _modules;

  // ---------------------------------------------------------------------------
  // All modules — used as the fallback when the API is unavailable.
  // These mirror the hardcoded cards that were previously in modules_grid.dart.
  // ---------------------------------------------------------------------------
  static final List<DashboardModuleModel> _allModules = [
    const DashboardModuleModel(
      key: 'patient_registration',
      title: 'Patient Registration',
      subtitle: 'Register new\nanimal patient',
      route: '/registration-dashboard',
    ),
    const DashboardModuleModel(
      key: 'qr_management',
      title: 'QR Management',
      subtitle: 'Generate, scan &\nmanage QR codes',
      route: '/qr-scanner',
    ),
    const DashboardModuleModel(
      key: 'patient_history',
      title: 'Patient History',
      subtitle: 'View complete\ntreatment history',
      route: '/animal-overview',
    ),
    const DashboardModuleModel(
      key: 'treatment_cycle',
      title: 'Treatment Cycle',
      subtitle: 'Manage treatment\nand recovery',
      route: '/treatment-dashboard',
    ),
    const DashboardModuleModel(
      key: 'diet_management',
      title: 'Diet Management',
      subtitle: 'Disease-based\ndiet plans',
      route: '/diet-dashboard',
    ),
    const DashboardModuleModel(
      key: 'ambulance',
      title: 'Ambulance',
      subtitle: 'Rescue requests &\nnotifications',
      route: '/ambulance-dashboard',
    ),
    const DashboardModuleModel(
      key: 'employees',
      title: 'Employees',
      subtitle: 'Manage staff &\nroles',
      route: '/employee-dashboard',
    ),
    const DashboardModuleModel(
      key: 'voice_notes',
      title: 'Voice Notes',
      subtitle: 'Add voice notes\n& updates',
      route: '/voice-notes-dashboard',
    ),
    const DashboardModuleModel(
      key: 'settings',
      title: 'Settings',
      subtitle: 'App settings &\npreferences',
      route: null,
    ),
    // ── Super Admin only ────────────────────────────────────────────
    const DashboardModuleModel(
      key: 'role_management',
      title: 'Role Mgmt',
      subtitle: 'Assign roles\nto staff',
      route: '/role-management',
    ),
    const DashboardModuleModel(
      key: 'admin_analytics',
      title: 'Analytics',
      subtitle: 'Tasks &\nperformance',
      route: '/admin-analytics',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  /// Fetch modules from the backend.
  ///
  /// On any failure (network, server, parse), falls back silently to [_allModules].
  Future<void> loadModules() async {
    if (_isLoading) return;

    AppLogger.info('DashboardModulesProvider', 'Fetching role-based modules...');

    _isLoading = true;
    _isUsingFallback = false;
    notifyListeners();

    try {
      final response = await _apiService.getModules();

      if (response.success && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Extract optional role name
        _userRole = data['role'] as String?;

        // Parse module list
        final rawList = data['modules'];
        if (rawList is List && rawList.isNotEmpty) {
          _modules = rawList
              .whereType<Map<String, dynamic>>()
              .map(DashboardModuleModel.fromJson)
              .toList();

          AppLogger.info(
            'DashboardModulesProvider',
            '✅ Loaded ${_modules.length} modules for role: $_userRole',
          );
        } else {
          // Empty list from backend → show all
          _useFallback('Empty modules list from backend');
        }
      } else {
        // API returned a non-success status
        _useFallback('API error: ${response.errorMessage}');
      }
    } catch (e, stackTrace) {
      // Any exception (network, JSON parse, etc.)
      _useFallback('Exception: $e');
      AppLogger.error(
        'DashboardModulesProvider',
        'loadModules failed → $e\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload from the backend (e.g. after role change or manual retry).
  Future<void> reload() async {
    _modules = [];
    await loadModules();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _useFallback(String reason) {
    AppLogger.info(
      'DashboardModulesProvider',
      '⚠️ Falling back to all modules. Reason: $reason',
    );
    _isUsingFallback = true;
    _modules = List.from(_allModules);
  }
}
