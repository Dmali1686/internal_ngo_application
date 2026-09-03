/// Models for the Food Department feeding schedule API.
///
/// Matches the TypeScript interfaces defined in the backend handoff document:
///   - [DailyScheduleResponse]   ← GET /api/v1/food-dept/schedule/today
///   - [PatientSchedule]
///   - [SlotSchedule]
///   - [FeedingTask]
///   - [CompleteTaskResponse]    ← PATCH /api/v1/food-dept/tasks/{id}/complete

class DailyScheduleResponse {
  final String date;
  final int totalAnimals;
  final int animalsPending;
  final int animalsCompleted;
  final int totalTasks;
  final int pendingTasks;
  final int completedTasks;
  final int morningTasks;
  final int afternoonTasks;
  final int eveningTasks;
  final List<PatientSchedule> schedule;

  const DailyScheduleResponse({
    required this.date,
    required this.totalAnimals,
    required this.animalsPending,
    required this.animalsCompleted,
    required this.totalTasks,
    required this.pendingTasks,
    required this.completedTasks,
    this.morningTasks = 0,
    this.afternoonTasks = 0,
    this.eveningTasks = 0,
    required this.schedule,
  });

  factory DailyScheduleResponse.fromJson(Map<String, dynamic> json) {
    return DailyScheduleResponse(
      date: json['date'] as String? ?? '',
      totalAnimals: json['total_animals'] as int? ?? 0,
      animalsPending: json['animals_pending'] as int? ?? 0,
      animalsCompleted: json['animals_completed'] as int? ?? 0,
      totalTasks: json['total_tasks'] as int? ?? 0,
      pendingTasks: json['pending_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      morningTasks: json['morning_tasks'] as int? ?? 0,
      afternoonTasks: json['afternoon_tasks'] as int? ?? 0,
      eveningTasks: json['evening_tasks'] as int? ?? 0,
      schedule: (json['schedule'] as List<dynamic>? ?? [])
          .map((e) => PatientSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PatientSchedule {
  final String patientId;
  final String caseId;
  final String? animalName;
  final String animalType;
  final String? cageNumber;
  final List<SlotSchedule> slots;

  const PatientSchedule({
    required this.patientId,
    required this.caseId,
    this.animalName,
    required this.animalType,
    this.cageNumber,
    required this.slots,
  });

  factory PatientSchedule.fromJson(Map<String, dynamic> json) {
    return PatientSchedule(
      patientId: json['patient_id'] as String? ?? '',
      caseId: json['case_id'] as String? ?? '',
      animalName: json['animal_name'] as String?,
      animalType: json['animal_type'] as String? ?? '',
      cageNumber: json['cage_number'] as String?,
      slots: (json['slots'] as List<dynamic>? ?? [])
          .map((e) => SlotSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Display name — falls back to "(unnamed)" if null.
  String get displayName => animalName ?? '(unnamed)';

  /// Emoji icon based on animal type.
  String get animalEmoji {
    switch (animalType.toUpperCase()) {
      case 'DOG':
        return '🐕';
      case 'CAT':
        return '🐈';
      case 'BIRD':
        return '🐦';
      case 'RABBIT':
        return '🐇';
      case 'COW':
        return '🐄';
      default:
        return '🐾';
    }
  }
}

/// One time slot (MORNING / AFTERNOON / EVENING) for a patient.
class SlotSchedule {
  final String slot; // "MORNING" | "AFTERNOON" | "EVENING"
  final List<FeedingTask> items;

  const SlotSchedule({required this.slot, required this.items});

  factory SlotSchedule.fromJson(Map<String, dynamic> json) {
    return SlotSchedule(
      slot: json['slot'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => FeedingTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single feeding task item inside a slot.
class FeedingTask {
  final String id;
  final String status; // "PENDING" | "COMPLETED"
  final String foodItemName;
  final num quantity;
  final String unit;
  final String? instructions;
  final String? completedBy;
  final String? completedByName;
  final String? completedAt;
  final String? notes;

  const FeedingTask({
    required this.id,
    required this.status,
    required this.foodItemName,
    required this.quantity,
    required this.unit,
    this.instructions,
    this.completedBy,
    this.completedByName,
    this.completedAt,
    this.notes,
  });

  factory FeedingTask.fromJson(Map<String, dynamic> json) {
    return FeedingTask(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      foodItemName: json['food_item_name'] as String? ?? '',
      quantity: json['quantity'] as num? ?? 0,
      unit: json['unit'] as String? ?? '',
      instructions: json['instructions'] as String?,
      completedBy: json['completed_by'] as String?,
      completedByName: json['completed_by_name'] as String?,
      completedAt: json['completed_at'] as String?,
      notes: json['notes'] as String?,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isCompleted => status == 'COMPLETED';
}

/// Response for PATCH /food-dept/tasks/{taskId}/complete.
class CompleteTaskResponse {
  final String id;
  final String status;
  final String completedBy;
  final String completedAt;
  final String? notes;

  const CompleteTaskResponse({
    required this.id,
    required this.status,
    required this.completedBy,
    required this.completedAt,
    this.notes,
  });

  factory CompleteTaskResponse.fromJson(Map<String, dynamic> json) {
    return CompleteTaskResponse(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'COMPLETED',
      completedBy: json['completed_by'] as String? ?? '',
      completedAt: json['completed_at'] as String? ?? '',
      notes: json['notes'] as String?,
    );
  }
}
