/// Diet Management data models matching the backend Swagger spec.
///
/// Endpoints covered:
///   GET  /api/v1/diet/default-plans
///   POST /api/v1/diet/default-plans
///   GET  /api/v1/patients/{id}/diet/history
///   POST /api/v1/patients/{id}/diet/additional

// ---------------------------------------------------------------------------
// Shared — Food Item
// ---------------------------------------------------------------------------

class FoodItem {
  final String id;
  final String name;
  final String? description;
  final String? unit;
  final String? createdAt;
  final String? updatedAt;

  const FoodItem({
    required this.id,
    required this.name,
    this.description,
    this.unit,
    this.createdAt,
    this.updatedAt,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      unit: json['unit'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Patient Diet History
// ---------------------------------------------------------------------------

class PatientDietItem {
  final String id;
  final String? foodItemId;
  final FoodItem? foodItem;
  final String? frequency;
  final double quantity;
  final String? instructions;
  final String? patientDietId;
  final String? createdAt;

  const PatientDietItem({
    required this.id,
    this.foodItemId,
    this.foodItem,
    this.frequency,
    required this.quantity,
    this.instructions,
    this.patientDietId,
    this.createdAt,
  });

  factory PatientDietItem.fromJson(Map<String, dynamic> json) {
    return PatientDietItem(
      id: json['id'] as String? ?? '',
      foodItemId: json['food_item_id'] as String?,
      foodItem: json['food_item'] != null
          ? FoodItem.fromJson(json['food_item'] as Map<String, dynamic>)
          : null,
      frequency: json['frequency'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      instructions: json['instructions'] as String?,
      patientDietId: json['patient_diet_id'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class PatientDiet {
  final String id;
  final String? patientId;
  final String? status;       // ACTIVE | REPLACED | COMPLETED | CANCELLED
  final String? dietSource;   // DEFAULT | OVERRIDE | ADDITIONAL
  final String? startDate;
  final String? endDate;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final List<PatientDietItem> items;

  const PatientDiet({
    required this.id,
    this.patientId,
    this.status,
    this.dietSource,
    this.startDate,
    this.endDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    required this.items,
  });

  bool get isActive => status?.toUpperCase() == 'ACTIVE';
  bool get isDefault => dietSource?.toUpperCase() == 'DEFAULT';
  bool get isAdditional => dietSource?.toUpperCase() == 'ADDITIONAL';

  factory PatientDiet.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return PatientDiet(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String?,
      status: json['status'] as String?,
      dietSource: json['diet_source'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      items: rawItems
          .map((e) => PatientDietItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Default Diet Plans (Admin)
// ---------------------------------------------------------------------------

class DefaultDietPlanItem {
  final String id;
  final String? foodItemId;
  final FoodItem? foodItem;
  final String? frequency;
  final double quantity;
  final String? instructions;
  final String? planId;
  final String? createdAt;

  const DefaultDietPlanItem({
    required this.id,
    this.foodItemId,
    this.foodItem,
    this.frequency,
    required this.quantity,
    this.instructions,
    this.planId,
    this.createdAt,
  });

  factory DefaultDietPlanItem.fromJson(Map<String, dynamic> json) {
    return DefaultDietPlanItem(
      id: json['id'] as String? ?? '',
      foodItemId: json['food_item_id'] as String?,
      foodItem: json['food_item'] != null
          ? FoodItem.fromJson(json['food_item'] as Map<String, dynamic>)
          : null,
      frequency: json['frequency'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      instructions: json['instructions'] as String?,
      planId: json['plan_id'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class DefaultDietPlan {
  final String id;
  final String? animalType;
  final String? condition;
  final double? minWeight;
  final double? maxWeight;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final double? minTemperature;
  final double? maxTemperature;
  final int? priority;
  final String? createdAt;
  final String? updatedAt;
  final List<DefaultDietPlanItem> items;

  const DefaultDietPlan({
    required this.id,
    this.animalType,
    this.condition,
    this.minWeight,
    this.maxWeight,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.minTemperature,
    this.maxTemperature,
    this.priority,
    this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory DefaultDietPlan.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return DefaultDietPlan(
      id: json['id'] as String? ?? '',
      animalType: json['animal_type'] as String?,
      condition: json['condition'] as String?,
      minWeight: (json['min_weight'] as num?)?.toDouble(),
      maxWeight: (json['max_weight'] as num?)?.toDouble(),
      minAgeMonths: (json['min_age_months'] as num?)?.toInt(),
      maxAgeMonths: (json['max_age_months'] as num?)?.toInt(),
      minTemperature: (json['min_temperature'] as num?)?.toDouble(),
      maxTemperature: (json['max_temperature'] as num?)?.toDouble(),
      priority: (json['priority'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      items: rawItems
          .map((e) =>
              DefaultDietPlanItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Request Payloads
// ---------------------------------------------------------------------------

class AdditionalDietItemRequest {
  final String foodItemId;
  final double quantity;
  final String frequency; // ONCE_DAILY | TWICE_DAILY | THREE_TIMES_DAILY
  final String? instructions;

  const AdditionalDietItemRequest({
    required this.foodItemId,
    required this.quantity,
    required this.frequency,
    this.instructions,
  });

  Map<String, dynamic> toJson() => {
        'food_item_id': foodItemId,
        'quantity': quantity,
        'frequency': frequency,
        if (instructions != null && instructions!.isNotEmpty)
          'instructions': instructions,
      };
}

class CreateAdditionalDietRequest {
  final String startDate;
  final String? endDate;
  final List<AdditionalDietItemRequest> items;

  const CreateAdditionalDietRequest({
    required this.startDate,
    this.endDate,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'start_date': startDate,
        if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class DefaultDietPlanItemRequest {
  final String foodItemId;
  final double quantity;
  final String frequency;
  final String? instructions;

  const DefaultDietPlanItemRequest({
    required this.foodItemId,
    required this.quantity,
    required this.frequency,
    this.instructions,
  });

  Map<String, dynamic> toJson() => {
        'food_item_id': foodItemId,
        'quantity': quantity,
        'frequency': frequency,
        if (instructions != null && instructions!.isNotEmpty)
          'instructions': instructions,
      };
}

class CreateDefaultDietPlanRequest {
  final String animalType;
  final String condition;
  final double? minWeight;
  final double? maxWeight;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final double? minTemperature;
  final double? maxTemperature;
  final int priority;
  final List<DefaultDietPlanItemRequest> items;

  const CreateDefaultDietPlanRequest({
    required this.animalType,
    required this.condition,
    this.minWeight,
    this.maxWeight,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.minTemperature,
    this.maxTemperature,
    required this.priority,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'animal_type': animalType,
        'condition': condition,
        if (minWeight != null) 'min_weight': minWeight,
        if (maxWeight != null) 'max_weight': maxWeight,
        if (minAgeMonths != null) 'min_age_months': minAgeMonths,
        if (maxAgeMonths != null) 'max_age_months': maxAgeMonths,
        if (minTemperature != null) 'min_temperature': minTemperature,
        if (maxTemperature != null) 'max_temperature': maxTemperature,
        'priority': priority,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

// ---------------------------------------------------------------------------
// Enums as constants
// ---------------------------------------------------------------------------

class DietFrequency {
  DietFrequency._();
  static const String onceDaily = 'ONCE_DAILY';
  static const String twiceDaily = 'TWICE_DAILY';
  static const String threeTimesDaily = 'THREE_TIMES_DAILY';

  static const List<String> all = [onceDaily, twiceDaily, threeTimesDaily];

  static String label(String value) {
    switch (value) {
      case onceDaily:
        return 'Once Daily';
      case twiceDaily:
        return 'Twice Daily';
      case threeTimesDaily:
        return '3× Daily';
      default:
        return value;
    }
  }
}

class DietStatus {
  DietStatus._();
  static const String active = 'ACTIVE';
  static const String replaced = 'REPLACED';
  static const String completed = 'COMPLETED';
  static const String cancelled = 'CANCELLED';
}

class DietSource {
  DietSource._();
  static const String defaultSource = 'DEFAULT';
  static const String override_ = 'OVERRIDE';
  static const String additional = 'ADDITIONAL';
}
