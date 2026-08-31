import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/public_post_model.dart';
import '../services/public_post_api_service.dart';

/// State management provider for the Post Compose screen.
///
/// Holds all form field data, validation state, and handles
/// the API submission flow (create draft → upload media → publish).
class ComposePostProvider extends ChangeNotifier {
  // ── Form controllers ─────────────────────────────────────────────────────
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController donationAmountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  // Animal detail controllers (editable)
  final TextEditingController animalTypeController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController rescueLocationController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();

  // ── Emergency level ──────────────────────────────────────────────────────
  String _emergencyLevel = 'NORMAL';
  String get emergencyLevel => _emergencyLevel;

  void setEmergencyLevel(String level) {
    _emergencyLevel = level;
    notifyListeners();
  }

  // ── Tag text (for the post badge) ────────────────────────────────────────
  String _tagText = 'Need Help';
  String get tagText => _tagText;

  static const List<String> availableTags = [
    'Need Help',
    'Recovering',
    'Critical',
    'Adopted',
    'Looking for Home',
  ];

  void setTagText(String tag) {
    _tagText = tag;
    notifyListeners();
  }

  // ── Photos ───────────────────────────────────────────────────────────────
  List<XFile> _photos = [];
  List<XFile> get photos => List.unmodifiable(_photos);

  void setInitialPhotos(List<XFile> photos) {
    _photos = List.from(photos);
    notifyListeners();
  }

  void addPhoto(XFile photo) {
    if (_photos.length < 6) {
      _photos.add(photo);
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < _photos.length) {
      _photos.removeAt(index);
      notifyListeners();
    }
  }

  // ── Patient data (auto-filled from registration) ─────────────────────────
  Map<String, dynamic> _patientData = {};
  Map<String, dynamic> get patientData => _patientData;

  void setPatientData(Map<String, dynamic> data) {
    _patientData = data;
    // Pre-fill the controllers
    animalTypeController.text = data['animal_type']?.toString() ?? '';
    breedController.text = data['breed']?.toString() ?? '';
    colorController.text = data['color']?.toString() ?? '';
    genderController.text = data['gender']?.toString() ?? '';
    ageController.text = data['age']?.toString() ?? '';
    rescueLocationController.text = data['rescue_location']?.toString() ?? '';
    conditionController.text = data['condition']?.toString() ?? '';
    notifyListeners();
  }

  // ── Submit state ─────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  // ── Validation ───────────────────────────────────────────────────────────
  bool get isFormValid {
    return descriptionController.text.trim().isNotEmpty &&
        donationAmountController.text.trim().isNotEmpty &&
        (double.tryParse(donationAmountController.text.trim()) ?? 0) > 0;
  }

  // ── Submit flow ──────────────────────────────────────────────────────────
  Future<bool> submitPost() async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final apiService = PublicPostApiService();

      // Step 1: Upload photos (if any)
      final List<String> uploadedUrls = [];
      for (final photo in _photos) {
        try {
          final uploadResponse =
              await apiService.uploadMedia(filePath: photo.path);
          if (uploadResponse.success && uploadResponse.data != null) {
            final data = uploadResponse.data;
            if (data is Map<String, dynamic>) {
              final inner = data['data'];
              final src = (inner is Map<String, dynamic>) ? inner : data;
              final url = src['url']?.toString();
              if (url != null && url.isNotEmpty) {
                uploadedUrls.add(url);
              }
            }
          }
        } catch (e) {
          // Continue with remaining photos even if one fails
          debugPrint('Photo upload failed: $e');
        }
      }

      // Step 2: Create the post
      final request = PublicPostRequest(
        patientId: _patientData['patient_id']?.toString() ?? '',
        caseId: _patientData['case_id']?.toString() ?? '',
        title: titleController.text.trim().isNotEmpty
            ? titleController.text.trim()
            : 'Rescued ${_patientData['animal_type'] ?? 'Animal'} Needs Your Help',
        description: descriptionController.text.trim(),
        imageUrls: uploadedUrls,
        animalType: animalTypeController.text.trim().isNotEmpty ? animalTypeController.text.trim() : 'Unknown',
        breed: breedController.text.trim().isNotEmpty ? breedController.text.trim() : null,
        color: colorController.text.trim().isNotEmpty ? colorController.text.trim() : null,
        gender: genderController.text.trim().isNotEmpty ? genderController.text.trim() : null,
        age: ageController.text.trim().isNotEmpty ? ageController.text.trim() : null,
        rescueLocation: rescueLocationController.text.trim().isNotEmpty ? rescueLocationController.text.trim() : null,
        condition: conditionController.text.trim().isNotEmpty ? conditionController.text.trim() : null,
        tagText: _tagText,
        donationTargetAmount:
            double.tryParse(donationAmountController.text.trim()) ?? 0,
        emergencyLevel: _emergencyLevel,
      );

      final createResponse =
          await apiService.createPost(body: request.toJson());

      if (!createResponse.success) {
        _errorMessage =
            createResponse.errorMessage ?? 'Failed to create the post.';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      // Extract post ID from response
      String? postId;
      final responseData = createResponse.data;
      if (responseData is Map<String, dynamic>) {
        final inner = responseData['data'];
        final src = (inner is Map<String, dynamic>) ? inner : responseData;
        postId = src['id']?.toString();
      }

      // Step 3: Publish the post
      if (postId != null && postId.isNotEmpty) {
        final publishResponse = await apiService.publishPost(postId);
        if (!publishResponse.success) {
          _errorMessage =
              publishResponse.errorMessage ?? 'Failed to publish the post.';
          _isSubmitting = false;
          notifyListeners();
          return false;
        }
      }

      _isSuccess = true;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ── Cleanup ──────────────────────────────────────────────────────────────
  void resetForm() {
    descriptionController.clear();
    donationAmountController.clear();
    titleController.clear();
    animalTypeController.clear();
    breedController.clear();
    colorController.clear();
    genderController.clear();
    ageController.clear();
    rescueLocationController.clear();
    conditionController.clear();
    _emergencyLevel = 'NORMAL';
    _tagText = 'Need Help';
    _photos.clear();
    _patientData = {};
    _isSubmitting = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    donationAmountController.dispose();
    titleController.dispose();
    animalTypeController.dispose();
    breedController.dispose();
    colorController.dispose();
    genderController.dispose();
    ageController.dispose();
    rescueLocationController.dispose();
    conditionController.dispose();
    super.dispose();
  }
}
