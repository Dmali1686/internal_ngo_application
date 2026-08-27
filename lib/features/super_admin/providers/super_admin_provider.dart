import 'package:flutter/material.dart';
import '../models/super_admin_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';

/// Holds Super Admin session state.
///
/// Call [setRole] from the login screen after the user chooses a role.
class SuperAdminProvider extends ChangeNotifier {
  bool _isSuperAdmin = false;

  bool get isSuperAdmin => _isSuperAdmin;

  /// Called from the login screen when the user submits with a role selected.
  void setRole(String role) {
    final wasSuperAdmin = _isSuperAdmin;
    _isSuperAdmin = role.toLowerCase().replaceAll(' ', '') == 'superadmin';
    if (_isSuperAdmin != wasSuperAdmin) notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mock data — replace with API calls when backend is ready
  // ─────────────────────────────────────────────────────────────────────────

  SuperAdminStats get stats => SuperAdminStats(
        totalEmployees: departments.fold(0, (s, d) => s + d.totalEmployees),
        totalDepartments: departments.length,
        activeTasks: departments.fold(0, (s, d) => s + d.activeTasks),
        completedTasks: departments.fold(0, (s, d) => s + d.completedTasks),
      );

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<DepartmentModel> _departments = [];
  List<DepartmentModel> get departments => _departments;

  /// Fetch departments from the real backend API.
  Future<void> loadDepartments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = ApiClient();
      final response = await client.get(ApiEndpoints.departments);
      if (response.data != null) {
        final List<dynamic> data = response.data;
        _departments = data.map((e) => DepartmentModel.fromJson(e)).toList();
      }
    } catch (e) {
      _error = e.toString();
      AppLogger.error('SuperAdminProvider', 'Failed to load departments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final List<DepartmentEmployeeModel> employees = const [
    DepartmentEmployeeModel(
      id: 'emp001',
      name: 'Dr. Rohit Sharma',
      role: 'Veterinarian',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      assignedTasks: 12,
      status: EmployeeStatus.active,
      departmentIds: ['medical', 'food'],
    ),
    DepartmentEmployeeModel(
      id: 'emp002',
      name: 'Dr. Priya Mehta',
      role: 'Veterinary Surgeon',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      assignedTasks: 8,
      status: EmployeeStatus.active,
      departmentIds: ['medical'],
    ),
    DepartmentEmployeeModel(
      id: 'emp003',
      name: 'Dr. Sameer Khan',
      role: 'Medical Officer',
      avatarUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
      assignedTasks: 7,
      status: EmployeeStatus.active,
      departmentIds: ['medical', 'operations'],
    ),
    DepartmentEmployeeModel(
      id: 'emp004',
      name: 'Dr. Karan Verma',
      role: 'Animal Care Specialist',
      avatarUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
      assignedTasks: 5,
      status: EmployeeStatus.busy,
      departmentIds: ['medical', 'transport'],
    ),
    DepartmentEmployeeModel(
      id: 'emp005',
      name: 'Anita Desai',
      role: 'Transport Coordinator',
      avatarUrl: 'https://randomuser.me/api/portraits/women/29.jpg',
      assignedTasks: 9,
      status: EmployeeStatus.active,
      departmentIds: ['transport'],
    ),
    DepartmentEmployeeModel(
      id: 'emp006',
      name: 'Rahul Nair',
      role: 'Operations Manager',
      avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
      assignedTasks: 14,
      status: EmployeeStatus.active,
      departmentIds: ['operations', 'fundraising'],
    ),
  ];

  /// Returns employees belonging to [departmentId].
  List<DepartmentEmployeeModel> employeesFor(String departmentId) =>
      employees.where((e) => e.departmentIds.contains(departmentId)).toList();

  /// Tasks for employee [employeeId].
  List<TaskItem> tasksFor(String employeeId) {
    switch (employeeId) {
      case 'emp001':
        return const [
          TaskItem(
            id: 't1',
            title: 'Rescue Dog #21 Treatment',
            departmentName: 'Medical Management',
            deadline: '12 May 2025',
            status: TaskStatus.completed,
          ),
          TaskItem(
            id: 't2',
            title: 'Injury Treatment – Case #45',
            departmentName: 'Medical Management',
            deadline: '10 May 2025',
            status: TaskStatus.completed,
          ),
          TaskItem(
            id: 't3',
            title: 'Vaccination Camp – May 2025',
            departmentName: 'Medical Management',
            deadline: '18 May 2025',
            status: TaskStatus.inProgress,
          ),
          TaskItem(
            id: 't4',
            title: 'Daily Health Check Report',
            departmentName: 'Medical Management',
            deadline: '20 May 2025',
            status: TaskStatus.pending,
          ),
        ];
      default:
        return const [
          TaskItem(
            id: 'td1',
            title: 'Weekly Report Submission',
            departmentName: 'Operations',
            deadline: '25 May 2025',
            status: TaskStatus.inProgress,
          ),
          TaskItem(
            id: 'td2',
            title: 'Team Meeting Agenda',
            departmentName: 'Operations',
            deadline: '22 May 2025',
            status: TaskStatus.pending,
          ),
        ];
    }
  }
}
