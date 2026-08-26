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
  final int animalTypeId;
  final String? rescueTripId;
  final int? breedId;
  final int? colorId;
  final String? animalName;
  final String? age;
  final double? weight;
  final String? gender;
  final String? reporterName;
  final String? reporterMobile;
  final String? reporterType;
  final String? address;
  final String? landmark;
  final String? description;
  final String? transportType;
  final String? rescuePriority;

  PatientRegistrationRequest({
    required this.animalTypeId,
    this.rescueTripId,
    this.breedId,
    this.colorId,
    this.animalName,
    this.age,
    this.weight,
    this.gender,
    this.reporterName,
    this.reporterMobile,
    this.reporterType,
    this.address,
    this.landmark,
    this.description,
    this.transportType,
    this.rescuePriority,
  });

  Map<String, dynamic> toJson() {
    return {
      'animal_type_id': animalTypeId,
      if (rescueTripId != null) 'rescue_trip_id': rescueTripId,
      if (breedId != null) 'breed_id': breedId,
      if (colorId != null) 'color_id': colorId,
      if (animalName != null) 'animal_name': animalName,
      if (age != null) 'age': age,
      if (weight != null) 'weight': weight,
      if (gender != null) 'gender': gender,
      if (reporterName != null) 'reporter_name': reporterName,
      if (reporterMobile != null) 'reporter_mobile': reporterMobile,
      if (reporterType != null) 'reporter_type': reporterType,
      if (address != null) 'address': address,
      if (landmark != null) 'landmark': landmark,
      if (description != null) 'description': description,
      if (transportType != null) 'transport_type': transportType,
      if (rescuePriority != null) 'rescue_priority': rescuePriority,
    };
  }
}
