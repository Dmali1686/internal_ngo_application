class PatientCaseModel {
  final String id;
  final String caseId;
  final String? cageNumber;
  final DateTime? admissionDate;
  final String? reporterName;
  final String? reporterMobile;
  final String? animalAddress;
  final String? animalType;
  final String? color;
  final String? gender;
  final String? age;
  final double? weight;
  final bool? isSterilized;
  final String? symptoms;
  final String? status;
  final String? qrPayload;

  PatientCaseModel({
    required this.id,
    required this.caseId,
    this.cageNumber,
    this.admissionDate,
    this.reporterName,
    this.reporterMobile,
    this.animalAddress,
    this.animalType,
    this.color,
    this.gender,
    this.age,
    this.weight,
    this.isSterilized,
    this.symptoms,
    this.status,
    this.qrPayload,
  });

  factory PatientCaseModel.fromJson(Map<String, dynamic> json) {
    return PatientCaseModel(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      cageNumber: json['cage_number'] as String?,
      admissionDate: json['admission_date'] != null
          ? DateTime.tryParse(json['admission_date'] as String)
          : null,
      reporterName: json['reporter_name'] as String?,
      reporterMobile: json['reporter_mobile'] as String?,
      animalAddress: json['animal_address'] as String?,
      animalType: json['animal_type'] as String?,
      color: json['color'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      isSterilized: json['is_sterilized'] as bool?,
      symptoms: json['symptoms'] as String?,
      status: json['status'] as String?,
      qrPayload: json['qr_payload'] as String?,
    );
  }
}
