import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';
import '../models/medicine_request_model.dart';
import '../services/medicine_api_service.dart';
import '../../../core/utils/logger.dart';

class MedicineProvider with ChangeNotifier {
  final MedicineApiService _apiService = MedicineApiService();

  List<MedicineModel> _medicines = [];
  List<MedicineModel> get medicines => _medicines;
  
  List<MedicineModel> _searchResults = [];
  List<MedicineModel> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Timer? _debounce;

  Future<void> fetchMedicines({
    bool refresh = false,
    String? search,
    bool? isActive,
    bool? lowStock,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _medicines.clear();
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMedicines(
        page: _currentPage,
        search: search,
        isActive: isActive,
        lowStock: lowStock,
      );

      _medicines.addAll(response.data);
      _totalPages = response.totalPages;
      _hasMore = _currentPage < _totalPages;
      if (_hasMore) {
        _currentPage++;
      }
    } catch (e) {
      AppLogger.error('MedicineProvider', 'Error fetching medicines: $e');
      _error = 'Error fetching medicines: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Debounced search specifically for Autocomplete fields (e.g. Treatment form)
  void searchMedicinesDebounced(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      _isSearching = true;
      notifyListeners();

      try {
        final response = await _apiService.getMedicines(
          page: 1,
          limit: 10,
          search: query,
          isActive: true, // we only want active medicines for treatment
        );
        _searchResults = response.data;
      } catch (e) {
        AppLogger.error('MedicineProvider', 'Search error: $e');
        _searchResults = [];
      } finally {
        _isSearching = false;
        notifyListeners();
      }
    });
  }

  /// Direct future-based search for Autocomplete's optionsBuilder
  Future<List<MedicineModel>> searchMedicinesFuture(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _apiService.getMedicines(
        page: 1,
        limit: 10,
        search: query,
        isActive: true,
      );
      return response.data;
    } catch (e) {
      AppLogger.error('MedicineProvider', 'Search future error: $e');
      return [];
    }
  }

  Future<bool> addMedicine(MedicineRequestModel request) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.addMedicines([request]);
      _isLoading = false;
      notifyListeners();
      // Refresh list
      fetchMedicines(refresh: true);
      return true;
    } catch (e) {
      AppLogger.error('MedicineProvider', 'Error adding medicine: $e');
      _error = 'Error adding medicine: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedicine(String id, MedicineRequestModel request) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.updateMedicine(id, request);
      _isLoading = false;
      notifyListeners();
      // Refresh list
      fetchMedicines(refresh: true);
      return true;
    } catch (e) {
      AppLogger.error('MedicineProvider', 'Error updating medicine: $e');
      _error = 'Error updating medicine: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMedicine(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteMedicine(id);
      _isLoading = false;
      notifyListeners();
      // Refresh list
      fetchMedicines(refresh: true);
      return true;
    } catch (e) {
      AppLogger.error('MedicineProvider', 'Error deleting medicine: $e');
      _error = 'Error deleting medicine: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
