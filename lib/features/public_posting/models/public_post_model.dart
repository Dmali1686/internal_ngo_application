/// Data models for the public posting feature.
///
/// These models map to the backend `/posts` endpoints used to
/// publish rescued‐animal posts to the public NGO application.

class PublicPostRequest {
  final String patientId;
  final String caseId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String animalType;
  final String? breed;
  final String? color;
  final String? gender;
  final String? age;
  final String? rescueLocation;
  final String? condition;
  final String tagText;
  final double donationTargetAmount;
  final String emergencyLevel; // 'NORMAL', 'URGENT', 'CRITICAL'

  PublicPostRequest({
    required this.patientId,
    required this.caseId,
    required this.title,
    required this.description,
    this.imageUrls = const [],
    required this.animalType,
    this.breed,
    this.color,
    this.gender,
    this.age,
    this.rescueLocation,
    this.condition,
    this.tagText = 'Need Help',
    required this.donationTargetAmount,
    this.emergencyLevel = 'NORMAL',
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'case_id': caseId,
      'title': title,
      'description': description,
      'image_urls': imageUrls,
      'animal_type': animalType,
      if (breed != null) 'breed': breed,
      if (color != null) 'color': color,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (rescueLocation != null) 'rescue_location': rescueLocation,
      if (condition != null) 'condition': condition,
      'tag_text': tagText,
      'donation_target_amount': donationTargetAmount,
      'emergency_level': emergencyLevel,
    };
  }
}

class PublicPostResponse {
  final String id;
  final String patientId;
  final String caseId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String animalType;
  final String? tagText;
  final double donationTargetAmount;
  final String emergencyLevel;
  final String status; // 'DRAFT', 'PUBLISHED'
  final String? createdAt;

  PublicPostResponse({
    required this.id,
    required this.patientId,
    required this.caseId,
    required this.title,
    required this.description,
    this.imageUrls = const [],
    required this.animalType,
    this.tagText,
    required this.donationTargetAmount,
    required this.emergencyLevel,
    required this.status,
    this.createdAt,
  });

  factory PublicPostResponse.fromJson(Map<String, dynamic> json) {
    return PublicPostResponse(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      caseId: json['case_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      animalType: json['animal_type']?.toString() ?? '',
      tagText: json['tag_text']?.toString(),
      donationTargetAmount:
          (json['donation_target_amount'] as num?)?.toDouble() ?? 0,
      emergencyLevel: json['emergency_level']?.toString() ?? 'NORMAL',
      status: json['status']?.toString() ?? 'DRAFT',
      createdAt: json['created_at']?.toString(),
    );
  }
}
