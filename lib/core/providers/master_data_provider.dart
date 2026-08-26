import 'package:flutter/material.dart';
import '../services/master_data_api_service.dart';

class MasterDataProvider extends ChangeNotifier {
  final MasterDataApiService _apiService = MasterDataApiService();

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> animalTypes = [];
  List<Map<String, dynamic>> breeds = [];
  List<Map<String, dynamic>> colors = [];

  Future<void> loadMasterData() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getAnimalTypes(),
        _apiService.getBreeds(),
        _apiService.getColors(),
      ]);

      final animalTypesRes = results[0];
      final breedsRes = results[1];
      final colorsRes = results[2];

      if (animalTypesRes.success && animalTypesRes.data != null) {
        animalTypes = List<Map<String, dynamic>>.from(animalTypesRes.data);
      }

      if (breedsRes.success && breedsRes.data != null) {
        breeds = List<Map<String, dynamic>>.from(breedsRes.data);
      }

      if (colorsRes.success && colorsRes.data != null) {
        colors = List<Map<String, dynamic>>.from(colorsRes.data);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
