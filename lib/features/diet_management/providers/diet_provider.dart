import 'package:flutter/foundation.dart';
import '../models/diet_models.dart';
import '../services/diet_api_service.dart';
import '../../../core/utils/app_error_handler.dart';
import '../../../core/utils/logger.dart';

/// Manages all diet-related state for both the patient view
/// (diet history, additional diets) and the admin view (default plan rules).
class DietProvider with ChangeNotifier {
  final DietApiService _service = DietApiService();

  // ─────────────────────── Patient Diet History ───────────────────────

  List<PatientDiet> _dietHistory = [];
  List<PatientDiet> get dietHistory => _dietHistory;

  /// Only diets with status ACTIVE.
  List<PatientDiet> get activeDiets =>
      _dietHistory.where((d) => d.isActive).toList();

  /// The primary DEFAULT diet (first active default entry).
  PatientDiet? get activeDefaultDiet =>
      _dietHistory.where((d) => d.isActive && d.isDefault).firstOrNull;

  // ─────────────────────── Default Diet Plans (Admin) ───────────────────────

  List<DefaultDietPlan> _defaultPlans = [];
  List<DefaultDietPlan> get defaultPlans => _defaultPlans;

  /// All unique food items extracted from default plans (used as picker source).
  List<FoodItem> get availableFoodItems {
    final seen = <String>{};
    final result = <FoodItem>[];
    for (final plan in _defaultPlans) {
      for (final item in plan.items) {
        if (item.foodItem != null && !seen.contains(item.foodItem!.id)) {
          seen.add(item.foodItem!.id);
          result.add(item.foodItem!);
        }
      }
    }
    return result;
  }

  // ─────────────────────── Loading / Error State ───────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  // ─────────────────────── Actions ───────────────────────

  /// Fetches the full diet history for [patientId] from
  /// `GET /api/v1/patients/{id}/diet/history`.
  Future<void> fetchDietHistory(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dietHistory = await _service.getDietHistory(patientId);
    } catch (e) {
      AppLogger.error('DietProvider', 'fetchDietHistory: $e');
      _error = AppErrorHandler.translate(e);
      _dietHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits an additional diet for [patientId] via
  /// `POST /api/v1/patients/{id}/diet/additional`, then refreshes history.
  Future<bool> addAdditionalDiet(
    String patientId,
    CreateAdditionalDietRequest request,
  ) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _service.addAdditionalDiet(patientId, request);
      // Refresh the full list after successful add
      await fetchDietHistory(patientId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('DietProvider', 'addAdditionalDiet: $e');
      _error = AppErrorHandler.translate(e);
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetches all default diet plan rules via
  /// `GET /api/v1/diet/default-plans`.
  Future<void> fetchDefaultDietPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _defaultPlans = await _service.getDefaultDietPlans();
    } catch (e) {
      AppLogger.error('DietProvider', 'fetchDefaultDietPlans: $e');
      _error = AppErrorHandler.translate(e);
      _defaultPlans = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new default diet plan rule via
  /// `POST /api/v1/diet/default-plans`, then refreshes the list.
  Future<bool> createDefaultDietPlan(
      CreateDefaultDietPlanRequest request) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createDefaultDietPlan(request);
      await fetchDefaultDietPlans();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('DietProvider', 'createDefaultDietPlan: $e');
      _error = AppErrorHandler.translate(e);
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _dietHistory = [];
    _defaultPlans = [];
    _isLoading = false;
    _isSubmitting = false;
    _error = null;
    notifyListeners();
  }
}
