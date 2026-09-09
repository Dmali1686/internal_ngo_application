class MedicineModel {
  final String id;
  final String name;
  final String? description;
  final String? medicineType;
  final String? unit;
  final int currentStock;
  final int minimumStock;
  final bool isActive;
  final String? expiryDate;

  MedicineModel({
    required this.id,
    required this.name,
    this.description,
    this.medicineType,
    this.unit,
    required this.currentStock,
    required this.minimumStock,
    required this.isActive,
    this.expiryDate,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      medicineType: json['medicine_type'] as String?,
      unit: json['unit'] as String?,
      currentStock: (json['current_stock'] as num?)?.toInt() ?? 0,
      minimumStock: (json['minimum_stock'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      expiryDate: json['expiry_date'] as String?,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: (pagination['page'] as num?)?.toInt() ?? 1,
      limit: (pagination['limit'] as num?)?.toInt() ?? 20,
      total: (pagination['total'] as num?)?.toInt() ?? 0,
      totalPages: (pagination['total_pages'] as num?)?.toInt() ?? 0,
    );
  }
}
