/// Department model returned by GET /api/v1/departments
class DepartmentModel {
  final String id;
  final String departmentCode;
  final String name;
  final String description;
  final bool isActive;

  const DepartmentModel({
    required this.id,
    required this.departmentCode,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id:             json['id'] as String,
      departmentCode: json['department_code'] as String,
      name:           json['name'] as String,
      description:    (json['description'] as String?) ?? '',
      isActive:       (json['is_active'] as bool?) ?? true,
    );
  }

  @override
  String toString() => 'DepartmentModel(id: $id, name: $name)';
}
