import 'package:flutter/material.dart';

import '../../../core/utils/app_error_handler.dart';
import '../../../core/utils/logger.dart';
import '../models/employee_detail_model.dart';
import '../services/employee_detail_service.dart';

/// State for the Employee Detail screen.
///
/// Manages loading / error / data lifecycle for
/// `GET /departments/{id}/employees/{user_id}`.
class EmployeeDetailProvider extends ChangeNotifier {
  final EmployeeDetailService _service = EmployeeDetailService();

  bool _isLoading = false;
  String? _error;
  EmployeeDetailResponse? _data;

  bool get isLoading => _isLoading;
  String? get error => _error;
  EmployeeDetailResponse? get data => _data;
  bool get hasData => _data != null;

  /// Loads employee details for the given [departmentId] and [userId].
  Future<void> load({
    required String departmentId,
    required String userId,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;
    if (_data != null && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('EmployeeDetailProvider', 'Loading details for user $userId in dept $departmentId');
      _data = await _service.getEmployeeDetail(
        departmentId: departmentId,
        userId: userId,
      );
      AppLogger.info('EmployeeDetailProvider', 'Loaded successfully.');
    } catch (e) {
      _error = AppErrorHandler.translate(e);
      AppLogger.error('EmployeeDetailProvider', 'Failed to load: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Forces a fresh fetch.
  Future<void> refresh({
    required String departmentId,
    required String userId,
  }) =>
      load(departmentId: departmentId, userId: userId, forceRefresh: true);
}
