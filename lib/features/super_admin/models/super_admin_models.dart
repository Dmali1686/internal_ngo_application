/// Data models for the Super Admin Management Dashboard.
///
/// These are purely client-side models. When the backend is ready,
/// replace the mock data in [SuperAdminProvider] with real API calls
/// that deserialize into these structures.
library super_admin_models;

// ─────────────────────────────────────────────────────────────────────────────
// Department
// ─────────────────────────────────────────────────────────────────────────────

class DepartmentModel {
  final String id;
  final String name;
  final String iconKey; // maps to an IconData in the UI layer
  final int totalEmployees;
  final int activeTasks;
  final int completedTasks;
  final int pendingTasks;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.totalEmployees,
    required this.activeTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?) ?? 'Unknown';
    String iconKey = 'operations';
    final nameLower = name.toLowerCase();
    
    if (nameLower.contains('medical')) iconKey = 'medical';
    else if (nameLower.contains('transport')) iconKey = 'transport';
    else if (nameLower.contains('food')) iconKey = 'food';
    else if (nameLower.contains('social')) iconKey = 'social_media';
    else if (nameLower.contains('fundraising')) iconKey = 'fundraising';

    return DepartmentModel(
      id: (json['id'] as String?) ?? '',
      name: name,
      iconKey: iconKey,
      totalEmployees: 0, // Backend doesn't return stats yet
      activeTasks: 0,
      completedTasks: 0,
      pendingTasks: 0,
    );
  }

  int get totalTasks => activeTasks + completedTasks + pendingTasks;

  /// Completion percentage (0–100).
  int get completionPct =>
      totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).round();
}

// ─────────────────────────────────────────────────────────────────────────────
// Employee (department-level listing)
// ─────────────────────────────────────────────────────────────────────────────

enum EmployeeStatus { active, busy, offline }

class DepartmentEmployeeModel {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final int assignedTasks;
  final EmployeeStatus status;
  final List<String> departmentIds; // departments this employee belongs to

  const DepartmentEmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.assignedTasks,
    required this.status,
    required this.departmentIds,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Task (employee task list)
// ─────────────────────────────────────────────────────────────────────────────

enum TaskStatus { completed, inProgress, pending }

class TaskItem {
  final String id;
  final String title;
  final String departmentName;
  final String deadline; // formatted display string e.g. "12 May 2025"
  final TaskStatus status;

  const TaskItem({
    required this.id,
    required this.title,
    required this.departmentName,
    required this.deadline,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Top-level analytics snapshot (home dashboard)
// ─────────────────────────────────────────────────────────────────────────────

class SuperAdminStats {
  final int totalEmployees;
  final int totalDepartments;
  final int activeTasks;
  final int completedTasks;

  const SuperAdminStats({
    required this.totalEmployees,
    required this.totalDepartments,
    required this.activeTasks,
    required this.completedTasks,
  });
}
