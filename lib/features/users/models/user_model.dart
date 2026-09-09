/// Models for the GET /api/v1/users response.
///
/// Endpoint: GET /api/v1/users (Super Admin only)
library user_model;

class UserAssignment {
  final String departmentId;
  final String departmentName;
  final String positionId;
  final String positionName;
  final String accessCategory;
  final bool isPrimary;

  const UserAssignment({
    required this.departmentId,
    required this.departmentName,
    required this.positionId,
    required this.positionName,
    required this.accessCategory,
    required this.isPrimary,
  });

  factory UserAssignment.fromJson(Map<String, dynamic> json) {
    return UserAssignment(
      departmentId: json['department_id']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
      positionId: json['position_id']?.toString() ?? '',
      positionName: json['position_name']?.toString() ?? '',
      accessCategory: json['access_category']?.toString() ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

class UserModel {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String mobile;
  final bool isActive;
  final List<UserAssignment> assignments;

  const UserModel({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.isActive,
    required this.assignments,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      assignments: ((json['assignments'] as List?) ?? [])
          .map((e) => UserAssignment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns initials for avatar fallback (up to 2 chars).
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Returns true if this user is assigned to the given department.
  bool isInDepartment(String departmentId) {
    return assignments.any((a) => a.departmentId == departmentId);
  }
}
