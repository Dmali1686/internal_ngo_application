class UserCreationRequest {
  final String email;
  final String fullName;
  final String mobile;
  final String password;
  final String username;

  const UserCreationRequest({
    required this.email,
    required this.fullName,
    required this.mobile,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        "email": email,
        "full_name": fullName,
        "mobile": mobile,
        "password": password,
        "username": username,
      };
}

class AssignmentItem {
  final String accessCategoryId;
  final String departmentId;
  final String positionId;
  final bool isPrimary;

  const AssignmentItem({
    required this.accessCategoryId,
    required this.departmentId,
    required this.positionId,
    required this.isPrimary,
  });

  Map<String, dynamic> toJson() => {
        "access_category_id": accessCategoryId,
        "department_id": departmentId,
        "position_id": positionId,
        "is_primary": isPrimary,
      };
}

class UserAssignmentRequest {
  final List<AssignmentItem> assignments;

  const UserAssignmentRequest({
    required this.assignments,
  });

  Map<String, dynamic> toJson() => {
        "assignments": assignments.map((e) => e.toJson()).toList(),
      };
}

class DepartmentItem {
  final String id;
  final String name;

  const DepartmentItem({required this.id, required this.name});

  factory DepartmentItem.fromJson(Map<String, dynamic> json) {
    return DepartmentItem(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class PositionItem {
  final String id;
  final String departmentId;
  final String name;

  const PositionItem({
    required this.id,
    required this.departmentId,
    required this.name,
  });

  factory PositionItem.fromJson(Map<String, dynamic> json) {
    return PositionItem(
      id: json['id'] as String,
      departmentId: json['department_id'] as String,
      name: json['name'] as String,
    );
  }
}

class AccessCategoryItem {
  final String id;
  final String name;

  const AccessCategoryItem({required this.id, required this.name});

  factory AccessCategoryItem.fromJson(Map<String, dynamic> json) {
    return AccessCategoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
