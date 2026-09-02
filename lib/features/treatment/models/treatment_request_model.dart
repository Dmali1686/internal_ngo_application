class TreatmentRequestModel {
  final String diagnosis;
  final List<TreatmentMedicineRequestModel> medicines;

  TreatmentRequestModel({
    required this.diagnosis,
    required this.medicines,
  });

  Map<String, dynamic> toJson() {
    return {
      'diagnosis': diagnosis,
      'medicines': medicines.map((e) => e.toJson()).toList(),
    };
  }
}

class TreatmentMedicineRequestModel {
  final String medicineId;
  final String dosage;
  final String frequency;
  final String duration;

  TreatmentMedicineRequestModel({
    required this.medicineId,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }
}
