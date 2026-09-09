/// Models for the Department Organization API response.
///
/// Endpoint: GET /api/v1/departments/{id}/organization
library department_org_model;

// ─────────────────────────────────────────────────────────────────────────────
// Employee
// ─────────────────────────────────────────────────────────────────────────────

class OrgEmployee {
  final String email;
  final String employeeCode;
  final String fullName;
  final String positionName;
  final List<String> tags;
  final String userId;

  const OrgEmployee({
    required this.email,
    required this.employeeCode,
    required this.fullName,
    required this.positionName,
    required this.tags,
    required this.userId,
  });

  factory OrgEmployee.fromJson(Map<String, dynamic> json) {
    return OrgEmployee(
      email: json['email']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      positionName: json['position_name']?.toString() ?? '',
      tags: List<String>.from(json['tags'] ?? []),
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

// ─────────────────────────────────────────────────────────────────────────────
// Department Details
// ─────────────────────────────────────────────────────────────────────────────

class OrgDepartmentDetails {
  final String id;
  final String name;
  final String departmentCode;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const OrgDepartmentDetails({
    required this.id,
    required this.name,
    required this.departmentCode,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrgDepartmentDetails.fromJson(Map<String, dynamic> json) {
    return OrgDepartmentDetails(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      departmentCode: json['department_code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Department Organization Response
// ─────────────────────────────────────────────────────────────────────────────

class DepartmentOrganizationResponse {
  final OrgDepartmentDetails department;
  final OrgEmployee? hod;
  final List<OrgEmployee> employees;
  final List<OrgEmployee> remainingEmployees;
  final int totalEmployees;

  const DepartmentOrganizationResponse({
    required this.department,
    this.hod,
    required this.employees,
    required this.remainingEmployees,
    required this.totalEmployees,
  });

  factory DepartmentOrganizationResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentOrganizationResponse(
      department: OrgDepartmentDetails.fromJson(
        (json['department'] as Map<String, dynamic>?) ?? {},
      ),
      hod: json['hod'] != null
          ? OrgEmployee.fromJson(json['hod'] as Map<String, dynamic>)
          : null,
      employees: ((json['employees'] as List?) ?? [])
          .map((e) => OrgEmployee.fromJson(e as Map<String, dynamic>))
          .toList(),
      remainingEmployees: ((json['remaining_employees'] as List?) ?? [])
          .map((e) => OrgEmployee.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEmployees: (json['total_employees'] as int?) ?? 0,
    );
  }

  /// All members: HOD first, then employees, then remaining.
  List<OrgEmployee> get allMembers => [
        if (hod != null) hod!,
        ...employees,
        ...remainingEmployees,
      ];
}
