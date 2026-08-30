import 'package:flutter/material.dart';

import '../models/patient_registration_model.dart';
import '../services/patient_api_service.dart';

/// State management for the paginated, filterable patient list screen.
class PatientListProvider extends ChangeNotifier {
  final PatientApiService _service = PatientApiService();

  // ── State ──────────────────────────────────────────────────────────────────
  List<PatientModel> _patients = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  static const int _pageSize = 20;

  // Active filters
  String _search = '';
  String? _status;
  String? _animalType;
  String? _gender;
  String? _fromDate;
  String? _toDate;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<PatientModel> get patients => _patients;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get total => _total;
  bool get hasNextPage => _currentPage <= _totalPages;
  bool get hasActiveFilters =>
      _search.isNotEmpty ||
      _status != null ||
      _animalType != null ||
      _gender != null ||
      (_fromDate != null && _toDate != null);

  String get search => _search;
  String? get status => _status;
  String? get animalType => _animalType;
  String? get gender => _gender;
  String? get fromDate => _fromDate;
  String? get toDate => _toDate;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Initial load / refresh: resets to page 1.
  Future<void> loadPatients({bool silent = false}) async {
    _currentPage = 1;
    _patients = [];
    _totalPages = 1;
    _error = null;
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    await _fetch();
    _isLoading = false;
    notifyListeners();
  }

  /// Load next page (infinite scroll).
  Future<void> loadMore() async {
    if (_isLoadingMore || _currentPage > _totalPages) return;
    _isLoadingMore = true;
    notifyListeners();
    await _fetch();
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Update search query and reload.
  Future<void> setSearch(String value) async {
    if (_search == value) return;
    _search = value;
    await loadPatients(silent: true);
  }

  /// Update status filter and reload.
  Future<void> setStatus(String? value) async {
    if (_status == value) return;
    _status = value;
    await loadPatients(silent: true);
  }

  /// Update animal type filter and reload.
  Future<void> setAnimalType(String? value) async {
    if (_animalType == value) return;
    _animalType = value;
    await loadPatients(silent: true);
  }

  /// Update gender filter and reload.
  Future<void> setGender(String? value) async {
    if (_gender == value) return;
    _gender = value;
    await loadPatients(silent: true);
  }

  /// Update date range and reload. Both must be provided together.
  Future<void> setDateRange(String? from, String? to) async {
    _fromDate = from;
    _toDate = to;
    await loadPatients(silent: true);
  }

  /// Clear all active filters and reload.
  Future<void> clearFilters() async {
    _search = '';
    _status = null;
    _animalType = null;
    _gender = null;
    _fromDate = null;
    _toDate = null;
    await loadPatients();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _fetch() async {
    try {
      final response = await _service.listPatients(
        page: _currentPage,
        limit: _pageSize,
        search: _search.isNotEmpty ? _search : null,
        status: _status,
        animalType: _animalType,
        gender: _gender,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final dataList = body['data'] as List<dynamic>? ?? [];
        final pagination = body['pagination'] as Map<String, dynamic>?;

        final newPatients = dataList
            .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
            .toList();

        _patients = [..._patients, ...newPatients];
        _total = (pagination?['total'] as num?)?.toInt() ?? _patients.length;
        _totalPages = (pagination?['total_pages'] as num?)?.toInt() ?? 1;
        _currentPage++;
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    }
  }
}
