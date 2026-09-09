import 'package:flutter/foundation.dart';
import '../models/patient_case_model.dart';
import '../models/treatment_request_model.dart';
import '../services/treatment_api_service.dart';
import '../../../core/utils/logger.dart';

class TreatmentProvider with ChangeNotifier {
  final TreatmentApiService _apiService = TreatmentApiService();

  PatientCaseModel? _patient;
  PatientCaseModel? get patient => _patient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Fetch patient details using Case ID from QR Scan
  Future<bool> fetchPatientByCaseId(String caseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPatientByCaseId(caseId);
      if (response.success && response.data != null) {
        final data = response.data is Map ? response.data : {'data': response.data};
        _patient = PatientCaseModel.fromJson(data['data'] ?? data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.errorMessage ?? 'Failed to load patient profile.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.error('TreatmentProvider', 'Error fetching patient: $e');
      _error = 'Error fetching patient: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Submit the new treatment form
  Future<bool> submitTreatment(TreatmentRequestModel request) async {
    if (_patient == null) {
      _error = 'No patient loaded to submit treatment to.';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.submitTreatment(_patient!.id, request.toJson());
      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.errorMessage ?? 'Failed to submit treatment.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.error('TreatmentProvider', 'Error submitting treatment: $e');
      _error = 'Error submitting treatment: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
