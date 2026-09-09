class MedicineRequestModel {
  final String name;
  final String? description;
  final String? medicineType;
  final String? unit;
  final int currentStock;
  final int minimumStock;
  final String? expiryDate;

  MedicineRequestModel({
    required this.name,
    this.description,
    this.medicineType,
    this.unit,
    this.currentStock = 0,
    this.minimumStock = 0,
    this.expiryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'medicine_type': medicineType,
      'unit': unit,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'expiry_date': expiryDate,
    };
  }
}
