class AccessCategoryModel {
  final String id;
  final String code;
  final String name;
  final bool isActive;

  AccessCategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory AccessCategoryModel.fromJson(Map<String, dynamic> json) {
    return AccessCategoryModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      isActive: json['is_active'],
    );
  }
}
