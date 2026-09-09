/// Models for the Department Employee Detail API response.
///
/// Endpoint: GET /api/v1/departments/{id}/employees/{user_id}
library employee_detail_model;

// ─────────────────────────────────────────────────────────────────────────────
// Task Summary
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeTaskSummary {
  final int completedTasks;
  final int inProgressTasks;
  final int overdueTasks;
  final int pendingTasks;
  final int totalTasks;

  const EmployeeTaskSummary({
    required this.completedTasks,
    required this.inProgressTasks,
    required this.overdueTasks,
    required this.pendingTasks,
    required this.totalTasks,
  });

  factory EmployeeTaskSummary.fromJson(Map<String, dynamic> json) {
    return EmployeeTaskSummary(
      completedTasks: (json['completed_tasks'] as int?) ?? 0,
      inProgressTasks: (json['in_progress_tasks'] as int?) ?? 0,
      overdueTasks: (json['overdue_tasks'] as int?) ?? 0,
      pendingTasks: (json['pending_tasks'] as int?) ?? 0,
      totalTasks: (json['total_tasks'] as int?) ?? 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeTask {
  final String assignedBy;
  final String dueDate;
  final String priority;
  final String status;
  final String taskCode;
  final String taskType;
  final String title;

  const EmployeeTask({
    required this.assignedBy,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.taskCode,
    required this.taskType,
    required this.title,
  });

  factory EmployeeTask.fromJson(Map<String, dynamic> json) {
    return EmployeeTask(
      assignedBy: json['assigned_by']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      taskCode: json['task_code']?.toString() ?? '',
      taskType: json['task_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Employee Detail Response
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeDetailResponse {
  final String accessCategory;
  final String email;
  final String employeeCode;
  final String fullName;
  final bool isPrimary;
  final String positionName;
  final EmployeeTaskSummary taskSummary;
  final List<EmployeeTask> tasks;
  final String userId;

  const EmployeeDetailResponse({
    required this.accessCategory,
    required this.email,
    required this.employeeCode,
    required this.fullName,
    required this.isPrimary,
    required this.positionName,
    required this.taskSummary,
    required this.tasks,
    required this.userId,
  });

  factory EmployeeDetailResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailResponse(
      accessCategory: json['access_category']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      positionName: json['position_name']?.toString() ?? '',
      taskSummary: EmployeeTaskSummary.fromJson(
        (json['task_summary'] as Map<String, dynamic>?) ?? {},
      ),
      tasks: ((json['tasks'] as List?) ?? [])
          .map((e) => EmployeeTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      userId: json['user_id']?.toString() ?? '',
    );
  }

  /// Returns initials for avatar fallback (up to 2 chars).
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
