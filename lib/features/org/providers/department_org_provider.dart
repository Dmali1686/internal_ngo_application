import 'package:flutter/material.dart';

import '../../../core/utils/app_error_handler.dart';
import '../models/department_org_model.dart';
import '../services/org_api_service.dart';

/// State for the Department Organization screen.
///
/// Manages loading / error / data lifecycle for
/// `GET /departments/{id}/organization`.
class DepartmentOrgProvider extends ChangeNotifier {
  final OrgApiService _service = OrgApiService();

  bool _isLoading = false;
  String? _error;
  DepartmentOrganizationResponse? _data;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DepartmentOrganizationResponse? get data => _data;

  bool get hasData => _data != null;

  /// Loads the organization chart for the given [departmentId].
  ///
  /// Set [forceRefresh] to `true` to bypass cached results.
  Future<void> load(String departmentId, {bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_data != null && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _service.getDepartmentOrganization(departmentId);
    } catch (e) {
      _error = AppErrorHandler.translate(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Forces a fresh fetch even if data is already loaded.
  Future<void> refresh(String departmentId) =>
      load(departmentId, forceRefresh: true);
}

