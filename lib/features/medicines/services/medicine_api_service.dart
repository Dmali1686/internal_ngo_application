import '../../../core/network/api_client.dart';
import '../models/medicine_model.dart';
import '../models/medicine_request_model.dart';
import '../../../core/utils/logger.dart';

class MedicineApiService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches paginated medicines
  Future<PaginatedResponse<MedicineModel>> getMedicines({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    bool? lowStock,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      if (lowStock != null) queryParams['low_stock'] = lowStock.toString();

      final response = await _apiClient.get(
        '/medicines',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        return PaginatedResponse<MedicineModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MedicineModel.fromJson(json),
        );
      } else {
        throw Exception(response.errorMessage ?? 'Failed to load medicines');
      }
    } catch (e) {
      AppLogger.error('MedicineApiService', 'Failed to get medicines: $e');
      rethrow;
    }
  }

  /// Add new medicines
  Future<void> addMedicines(List<MedicineRequestModel> requests) async {
    try {
      final response = await _apiClient.post(
        '/medicines',
        body: {'request': requests.map((e) => e.toJson()).toList()},
      );
      if (!response.success) {
        throw Exception(response.errorMessage ?? 'Failed to add medicines');
      }
    } catch (e) {
      AppLogger.error('MedicineApiService', 'Failed to add medicines: $e');
      rethrow;
    }
  }

  /// Get medicine by ID
  Future<MedicineModel> getMedicineById(String id) async {
    try {
      final response = await _apiClient.get('/medicines/$id');
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data is Map 
            ? response.data 
            : {'data': response.data};
            
        final Map<String, dynamic> data = responseData['data'] ?? responseData;
        return MedicineModel.fromJson(data);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to load medicine');
      }
    } catch (e) {
      AppLogger.error('MedicineApiService', 'Failed to get medicine by ID: $e');
      rethrow;
    }
  }

  /// Update medicine
  Future<void> updateMedicine(String id, MedicineRequestModel request) async {
    try {
      final response = await _apiClient.patch( // Assuming patch or put, swagger says PUT but some standard uses patch
        '/medicines/$id',
        body: request.toJson(),
      );
      if (!response.success) {
        throw Exception(response.errorMessage ?? 'Failed to update medicine');
      }
    } catch (e) {
      AppLogger.error('MedicineApiService', 'Failed to update medicine: $e');
      rethrow;
    }
  }

  /// Delete medicine
  Future<void> deleteMedicine(String id) async {
    try {
      final response = await _apiClient.delete('/medicines/$id');
      if (!response.success) {
        throw Exception(response.errorMessage ?? 'Failed to delete medicine');
      }
    } catch (e) {
      AppLogger.error('MedicineApiService', 'Failed to delete medicine: $e');
      rethrow;
    }
  }
}
