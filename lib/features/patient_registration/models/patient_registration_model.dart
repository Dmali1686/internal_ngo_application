class PatientRegistrationModel {
  // Reporter Details
  String reporterName;
  String reporterPhone;
  String? reporterId;

  // Rescue Location
  String address;
  String city;
  String? landmark;

  // Animal Information
  String animalType;
  String breed;
  String age;
  String gender;
  String color;

  // Medical Assessment
  String initialCondition;
  String visibleInjuries;
  String urgencyLevel;

  // Transport Details
  String transportMethod;

  PatientRegistrationModel({
    this.reporterName = '',
    this.reporterPhone = '',
    this.reporterId,
    this.address = '',
    this.city = '',
    this.landmark,
    this.animalType = 'Dog',
    this.breed = '',
    this.age = '',
    this.gender = 'Unknown',
    this.color = '',
    this.initialCondition = '',
    this.visibleInjuries = '',
    this.urgencyLevel = 'Normal',
    this.transportMethod = 'Ambulance',
  });

  PatientRegistrationModel copyWith({
    String? reporterName,
    String? reporterPhone,
    String? reporterId,
    String? address,
    String? city,
    String? landmark,
    String? animalType,
    String? breed,
    String? age,
    String? gender,
    String? color,
    String? initialCondition,
    String? visibleInjuries,
    String? urgencyLevel,
    String? transportMethod,
  }) {
    return PatientRegistrationModel(
      reporterName: reporterName ?? this.reporterName,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      reporterId: reporterId ?? this.reporterId,
      address: address ?? this.address,
      city: city ?? this.city,
      landmark: landmark ?? this.landmark,
      animalType: animalType ?? this.animalType,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      initialCondition: initialCondition ?? this.initialCondition,
      visibleInjuries: visibleInjuries ?? this.visibleInjuries,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      transportMethod: transportMethod ?? this.transportMethod,
    );
  }
}

class PatientRegistrationRequest {
  final String? age;
  final String? animalAddress;
  final String? animalName;
  final String? animalType;
  final String? cageNumber;
  final String? color;
  final String? diagnosis;
  final String? gender; // "MALE" or "FEMALE"
  final bool? isSterilized;
  final String? landmark;
  final String? reporterMobile;
  final String? reporterName;
  final String? symptoms;
  final String? tests;
  final String? transportedBy;
  final String? transporterContact;
  final double? weight;
  final double? temperature;

  PatientRegistrationRequest({
    this.age,
    this.animalAddress,
    this.animalName,
    this.animalType,
    this.cageNumber,
    this.color,
    this.diagnosis,
    this.gender,
    this.isSterilized,
    this.landmark,
    this.reporterMobile,
    this.reporterName,
    this.symptoms,
    this.tests,
    this.transportedBy,
    this.transporterContact,
    this.weight,
    this.temperature,
  });

  Map<String, dynamic> toJson() {
    return {
      if (age != null) 'age': age,
      if (animalAddress != null) 'animal_address': animalAddress,
      if (animalName != null) 'animal_name': animalName,
      if (animalType != null) 'animal_type': animalType,
      if (cageNumber != null) 'cage_number': cageNumber,
      if (color != null) 'color': color,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (gender != null) 'gender': gender,
      if (isSterilized != null) 'is_sterilized': isSterilized,
      if (landmark != null) 'landmark': landmark,
      if (reporterMobile != null) 'reporter_mobile': reporterMobile,
      if (reporterName != null) 'reporter_name': reporterName,
      if (symptoms != null) 'symptoms': symptoms,
      if (tests != null) 'tests': tests,
      if (transportedBy != null) 'transported_by': transportedBy,
      if (transporterContact != null) 'transporter_contact': transporterContact,
      if (weight != null) 'weight': weight,
      if (temperature != null) 'temperature': temperature,
    };
  }
}

// ---------------------------------------------------------------------------
// Patient response model — maps GET /api/v1/patients and GET /patients/{id}
// ---------------------------------------------------------------------------

class PatientModel {
  final String id;
  final String caseId;
  final String? cageNumber;
  final String? admissionDate;
  final String? reporterName;
  final String? reporterMobile;
  final String? animalAddress;
  final String? landmark;
  final String? animalName;
  final String animalType;
  final String? color;
  final String? gender;
  final String? age;
  final double? weight;
  final double? temperature;
  final bool? isSterilized;
  final String? transportedBy;
  final String? transporterContact;
  final String? symptoms;
  final String? tests;
  final String? diagnosis;
  final String status;
  final String? qrPayload;

  PatientModel({
    required this.id,
    required this.caseId,
    this.cageNumber,
    this.admissionDate,
    this.reporterName,
    this.reporterMobile,
    this.animalAddress,
    this.landmark,
    this.animalName,
    required this.animalType,
    this.color,
    this.gender,
    this.age,
    this.weight,
    this.temperature,
    this.isSterilized,
    this.transportedBy,
    this.transporterContact,
    this.symptoms,
    this.tests,
    this.diagnosis,
    required this.status,
    this.qrPayload,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString() ?? '',
      caseId: json['case_id']?.toString() ?? '',
      cageNumber: json['cage_number']?.toString(),
      admissionDate: json['admission_date']?.toString(),
      reporterName: json['reporter_name']?.toString(),
      reporterMobile: json['reporter_mobile']?.toString(),
      animalAddress: json['animal_address']?.toString(),
      landmark: json['landmark']?.toString(),
      animalName: json['animal_name']?.toString(),
      animalType: json['animal_type']?.toString() ?? '',
      color: json['color']?.toString(),
      gender: json['gender']?.toString(),
      age: json['age']?.toString(),
      weight: (json['weight'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      isSterilized: json['is_sterilized'] as bool?,
      transportedBy: json['transported_by']?.toString(),
      transporterContact: json['transporter_contact']?.toString(),
      symptoms: json['symptoms']?.toString(),
      tests: json['tests']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      status: json['status']?.toString() ?? 'ADMITTED',
      qrPayload: json['qr_payload']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'case_id': caseId,
    'cage_number': cageNumber,
    'admission_date': admissionDate,
    'reporter_name': reporterName,
    'reporter_mobile': reporterMobile,
    'animal_address': animalAddress,
    'landmark': landmark,
    'animal_name': animalName,
    'animal_type': animalType,
    'color': color,
    'gender': gender,
    'age': age,
    'weight': weight,
    'temperature': temperature,
    'is_sterilized': isSterilized,
    'transported_by': transportedBy,
    'transporter_contact': transporterContact,
    'symptoms': symptoms,
    'tests': tests,
    'diagnosis': diagnosis,
    'status': status,
    'qr_payload': qrPayload,
  };
}

// ---------------------------------------------------------------------------
// Medicine model
// ---------------------------------------------------------------------------

class MedicineModel {
  final String? id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? createdAt;

  MedicineModel({
    this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.createdAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id']?.toString(),
      medicineName: json['medicine_name']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'medicine_name': medicineName,
    'dosage': dosage,
    'frequency': frequency,
    'duration': duration,
  };
}

// ---------------------------------------------------------------------------
// Treatment model
// ---------------------------------------------------------------------------

class TreatmentModel {
  final String? id;
  final String? patientId;
  final String? treatmentDate;
  final String diagnosis;
  final String? doctorId;
  final List<MedicineModel> medicines;

  TreatmentModel({
    this.id,
    this.patientId,
    this.treatmentDate,
    required this.diagnosis,
    this.doctorId,
    this.medicines = const [],
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    final medicinesList = (json['medicines'] as List<dynamic>? ?? [])
        .map((m) => MedicineModel.fromJson(m as Map<String, dynamic>))
        .toList();
    return TreatmentModel(
      id: json['id']?.toString(),
      patientId: json['patient_id']?.toString(),
      treatmentDate: json['treatment_date']?.toString(),
      diagnosis: json['diagnosis']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString(),
      medicines: medicinesList,
    );
  }
}

// ---------------------------------------------------------------------------
// Add Treatment request
// ---------------------------------------------------------------------------

class AddTreatmentRequest {
  final String diagnosis;
  final String? doctorId;
  final List<MedicineModel> medicines;

  AddTreatmentRequest({
    required this.diagnosis,
    this.doctorId,
    this.medicines = const [],
  });

  Map<String, dynamic> toJson() => {
    'diagnosis': diagnosis,
    if (doctorId != null) 'doctor_id': doctorId,
    if (medicines.isNotEmpty)
      'medicines': medicines.map((m) => m.toJson()).toList(),
  };
}

