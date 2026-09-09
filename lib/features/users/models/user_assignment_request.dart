/// Request model for POST /api/v1/users/{id}/assignments
class UserAssignmentRequest {
  final String accessCategoryId;
  final String? departmentId;
  final String? positionId;
  final bool isPrimary;

  const UserAssignmentRequest({
    required this.accessCategoryId,
    this.departmentId,
    this.positionId,
    this.isPrimary = true,
  });

  Map<String, dynamic> toJson() => {
    'access_category_id': accessCategoryId,
    if (departmentId != null) 'department_id': departmentId,
    if (positionId != null)   'position_id':   positionId,
    'is_primary': isPrimary,
  };
}
