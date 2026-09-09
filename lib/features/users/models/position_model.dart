/// Position model returned by GET /api/v1/positions
class PositionModel {
  final String id;
  final String departmentId;
  final String positionCode;
  final String name;
  final bool isHod;
  final bool isActive;

  const PositionModel({
    required this.id,
    required this.departmentId,
    required this.positionCode,
    required this.name,
    required this.isHod,
    required this.isActive,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id:           json['id'] as String,
      departmentId: json['department_id'] as String,
      positionCode: json['position_code'] as String,
      name:         json['name'] as String,
      isHod:        (json['is_hod'] as bool?) ?? false,
      isActive:     (json['is_active'] as bool?) ?? true,
    );
  }

  @override
  String toString() => 'PositionModel(id: $id, name: $name, dept: $departmentId)';
}
