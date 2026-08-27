/// Analytics data model returned by `GET /api/v1/admin/analytics`.
///
/// Contains org-wide task KPIs and per-employee performance stats.
class AdminAnalyticsModel {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;

  final int totalEmployees;
  final int activeEmployees;

  /// Per-employee performance entries.
  final List<EmployeeStatModel> employeeStats;

  /// Distribution of employees per role key → count.
  final Map<String, int> roleDistribution;

  const AdminAnalyticsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.totalEmployees,
    required this.activeEmployees,
    required this.employeeStats,
    required this.roleDistribution,
  });

  /// Completion percentage (0.0 – 1.0).
  double get completionRate =>
      totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  /// Deserialise from the API response.
  factory AdminAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final stats = (json['employee_stats'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(EmployeeStatModel.fromJson)
        .toList();

    final roles = <String, int>{};
    final rawRoles = json['role_distribution'] as Map<String, dynamic>? ?? {};
    rawRoles.forEach((k, v) => roles[k] = (v as num?)?.toInt() ?? 0);

    return AdminAnalyticsModel(
      totalTasks: (json['total_tasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completed_tasks'] as num?)?.toInt() ?? 0,
      pendingTasks: (json['pending_tasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (json['overdue_tasks'] as num?)?.toInt() ?? 0,
      totalEmployees: (json['total_employees'] as num?)?.toInt() ?? 0,
      activeEmployees: (json['active_employees'] as num?)?.toInt() ?? 0,
      employeeStats: stats,
      roleDistribution: roles,
    );
  }

  /// Hardcoded fallback when API is not available.
  factory AdminAnalyticsModel.fallback() {
    return AdminAnalyticsModel(
      totalTasks: 148,
      completedTasks: 102,
      pendingTasks: 38,
      overdueTasks: 8,
      totalEmployees: 24,
      activeEmployees: 21,
      employeeStats: [
        EmployeeStatModel(name: 'Dr. Priya Sharma', role: 'doctor', assigned: 32, completed: 28, pending: 4),
        EmployeeStatModel(name: 'Ravi Desai', role: 'nurse', assigned: 26, completed: 20, pending: 6),
        EmployeeStatModel(name: 'Anita Kulkarni', role: 'caretaker', assigned: 18, completed: 15, pending: 3),
        EmployeeStatModel(name: 'Suresh Patil', role: 'driver', assigned: 14, completed: 12, pending: 2),
        EmployeeStatModel(name: 'Meera Joshi', role: 'nurse', assigned: 22, completed: 18, pending: 4),
      ],
      roleDistribution: {
        'doctor': 4,
        'nurse': 7,
        'caretaker': 6,
        'driver': 4,
        'receptionist': 3,
      },
    );
  }
}

/// Per-employee performance stats inside [AdminAnalyticsModel].
class EmployeeStatModel {
  final String name;
  final String role;
  final int assigned;
  final int completed;
  final int pending;

  const EmployeeStatModel({
    required this.name,
    required this.role,
    required this.assigned,
    required this.completed,
    required this.pending,
  });

  /// Completion percentage (0.0 – 1.0).
  double get completionRate => assigned == 0 ? 0.0 : completed / assigned;

  factory EmployeeStatModel.fromJson(Map<String, dynamic> json) {
    return EmployeeStatModel(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      assigned: (json['assigned'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
    );
  }
}
