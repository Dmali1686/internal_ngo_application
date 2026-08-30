import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class RegistrationProvider extends ChangeNotifier {
  // Callback to move to next step
  void Function([bool continueVoiceFlow])? onNextStepRequested;

  // Step 1: Reporter Details
  final TextEditingController reporterNameController = TextEditingController();
  final FocusNode reporterNameFocus = FocusNode();
  final TextEditingController mobileNumberController = TextEditingController();
  final FocusNode mobileNumberFocus = FocusNode();
  final TextEditingController alternateNumberController =
      TextEditingController();
  final FocusNode alternateNumberFocus = FocusNode();
  List<XFile> reporterPhotos = [];
  bool isEmergency = false;

  // Step 2: Location
  final TextEditingController addressController = TextEditingController();
  final FocusNode addressFocus = FocusNode();
  final TextEditingController landmarkController = TextEditingController();
  final FocusNode landmarkFocus = FocusNode();
  final TextEditingController areaController = TextEditingController();
  final FocusNode areaFocus = FocusNode();
  final TextEditingController cityController = TextEditingController();
  final FocusNode cityFocus = FocusNode();
  final TextEditingController pincodeController = TextEditingController();
  final FocusNode pincodeFocus = FocusNode();
  String priority = 'Normal';
  LatLng? mapLocation;

  String? _activeVoiceField;
  String? get activeVoiceField => _activeVoiceField;

  // Step 3: Animal Details
  final TextEditingController animalNameController = TextEditingController();
  String animalType = 'Dog';
  int? animalTypeId;
  final TextEditingController breedController = TextEditingController();
  final FocusNode breedFocus = FocusNode();
  int? breedId;
  int? colorId;
  final TextEditingController colorController = TextEditingController();
  final FocusNode colorFocus = FocusNode();
  String gender = 'Unknown';
  String age = 'Unknown';
  final TextEditingController weightController = TextEditingController();
  final FocusNode weightFocus = FocusNode();
  final TextEditingController microchipController = TextEditingController();
  bool isSterilized = false;
  bool hasCollar = false;
  Set<String> observations = {};

  // Step 5: Medical Assessment
  final TextEditingController symptomsController = TextEditingController();
  final FocusNode symptomsFocus = FocusNode();
  Set<String> symptomTags = {};
  final TextEditingController temperatureController = TextEditingController();
  final FocusNode temperatureFocus = FocusNode();
  final TextEditingController initialTreatmentController =
      TextEditingController();
  final FocusNode initialTreatmentFocus = FocusNode();
  final TextEditingController medicineStartedController =
      TextEditingController();
  Map<String, bool> requiredTests = {
    'Blood Test': false,
    'X-Ray': false,
    'CBC (Complete Blood Count)': false,
    'Ultrasound': false,
  };
  String wardAssignment = '';

  // Helpers to update state variables and notify listeners
  void setActiveVoiceField(String? val) {
    _activeVoiceField = val;
    notifyListeners();
  }

  void addReporterPhoto(XFile photo) {
    if (reporterPhotos.length < 4) {
      reporterPhotos.add(photo);
      notifyListeners();
    }
  }

  void removeReporterPhoto(int index) {
    reporterPhotos.removeAt(index);
    notifyListeners();
  }

  void updateIsEmergency(bool val) {
    isEmergency = val;
    notifyListeners();
  }

  void updatePriority(String val) {
    priority = val;
    notifyListeners();
  }

  void updateMapLocation(LatLng loc) {
    mapLocation = loc;
    notifyListeners();
  }

  void updateAnimalType(String val) {
    animalType = val;
    notifyListeners();
  }

  void updateAnimalTypeId(int? val) {
    animalTypeId = val;
    notifyListeners();
  }

  void updateBreedId(int? val) {
    breedId = val;
    notifyListeners();
  }

  void updateColorId(int? val) {
    colorId = val;
    notifyListeners();
  }

  void updateGender(String val) {
    gender = val;
    notifyListeners();
  }

  void updateAge(String val) {
    age = val;
    notifyListeners();
  }

  void updateSterilized(bool val) {
    isSterilized = val;
    notifyListeners();
  }

  void updateCollar(bool val) {
    hasCollar = val;
    notifyListeners();
  }

  void toggleObservation(String val) {
    if (observations.contains(val)) {
      observations.remove(val);
    } else {
      observations.add(val);
    }
    notifyListeners();
  }

  void toggleSymptomTag(String val) {
    if (symptomTags.contains(val)) {
      symptomTags.remove(val);
    } else {
      symptomTags.add(val);
    }
    notifyListeners();
  }

  void updateRequiredTest(String test, bool val) {
    requiredTests[test] = val;
    notifyListeners();
  }

  void updateWardAssignment(String val) {
    wardAssignment = val;
    notifyListeners();
  }

  // --- Data storage for the old standalone registration screens ---
  final Map<String, dynamic> _data = {};

  Map<String, dynamic> get data => _data;

  void updateReporterDetails({
    required String name,
    required String phone,
    String? id,
  }) {
    _data['reporterName'] = name;
    _data['reporterPhone'] = phone;
    _data['reporterId'] = id;
    // Also update the new-style controllers so voice flow can read them
    reporterNameController.text = name;
    mobileNumberController.text = phone;
    notifyListeners();
  }

  void updateRescueLocation({
    required String address,
    required String city,
    String? landmark,
  }) {
    _data['address'] = address;
    _data['city'] = city;
    _data['landmark'] = landmark;
    addressController.text = address;
    cityController.text = city;
    if (landmark != null) landmarkController.text = landmark;
    notifyListeners();
  }

  void updateAnimalInformation({
    required String type,
    required String breed,
    required String age,
    required String gender,
    required String color,
  }) {
    _data['animalType'] = type;
    _data['breed'] = breed;
    _data['age'] = age;
    _data['gender'] = gender;
    _data['color'] = color;
    animalType = type;
    breedController.text = breed;
    this.age = age;
    this.gender = gender;
    notifyListeners();
  }

  void updateMedicalAssessment({
    required String condition,
    required String injuries,
    required String urgency,
  }) {
    _data['condition'] = condition;
    _data['injuries'] = injuries;
    _data['urgency'] = urgency;
    symptomsController.text = condition;
    notifyListeners();
  }

  void updateTransportDetails({required String method}) {
    _data['transportMethod'] = method;
    notifyListeners();
  }

  void reset() {
    _data.clear();
    reporterNameController.clear();
    mobileNumberController.clear();
    alternateNumberController.clear();
    addressController.clear();
    landmarkController.clear();
    areaController.clear();
    cityController.clear();
    pincodeController.clear();
    animalNameController.clear();
    breedController.clear();
    weightController.clear();
    colorController.clear();
    microchipController.clear();
    symptomsController.clear();
    temperatureController.clear();
    initialTreatmentController.clear();
    medicineStartedController.clear();
    reporterPhotos.clear();
    priority = 'Normal';
    mapLocation = null;
    animalType = 'Dog';
    animalTypeId = null;
    breedId = null;
    colorId = null;
    gender = 'Unknown';
    age = 'Unknown';
    isSterilized = false;
    hasCollar = false;
    observations.clear();
    symptomTags.clear();
    requiredTests = {
      'Blood Test': false,
      'X-Ray': false,
      'CBC (Complete Blood Count)': false,
      'Ultrasound': false,
    };
    wardAssignment = '';
    notifyListeners();
  }

  @override
  void dispose() {
    reporterNameController.dispose();
    reporterNameFocus.dispose();
    mobileNumberController.dispose();
    mobileNumberFocus.dispose();
    alternateNumberController.dispose();
    alternateNumberFocus.dispose();
    addressController.dispose();
    addressFocus.dispose();
    landmarkController.dispose();
    landmarkFocus.dispose();
    areaController.dispose();
    areaFocus.dispose();
    cityController.dispose();
    cityFocus.dispose();
    pincodeController.dispose();
    pincodeFocus.dispose();
    animalNameController.dispose();
    breedController.dispose();
    breedFocus.dispose();
    colorController.dispose();
    colorFocus.dispose();
    weightController.dispose();
    weightFocus.dispose();
    microchipController.dispose();
    symptomsController.dispose();
    symptomsFocus.dispose();
    temperatureController.dispose();
    temperatureFocus.dispose();
    initialTreatmentController.dispose();
    initialTreatmentFocus.dispose();
    medicineStartedController.dispose();
    super.dispose();
  }
}
