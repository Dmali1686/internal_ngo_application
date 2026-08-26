import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';

/// Service for fetching master/reference data from the backend.
///
/// All methods use [ApiClient] which automatically prepends
/// the base URL (`http://192.168.1.35:8080/api/v1`).
class MasterDataApiService {
  final ApiClient _client = ApiClient();

  /// Fetch all active ambulances.
  /// `GET /api/v1/master/ambulances`
  Future<ApiResponse<dynamic>> getAmbulances() {
    return _client.get(ApiEndpoints.masterAmbulances);
  }

  /// Fetch all animal types.
  /// `GET /api/v1/master/animal-types`
  Future<ApiResponse<dynamic>> getAnimalTypes() {
    return _client.get(ApiEndpoints.masterAnimalTypes);
  }

  /// Fetch all breeds.
  /// `GET /api/v1/master/breeds`
  Future<ApiResponse<dynamic>> getBreeds() {
    return _client.get(ApiEndpoints.masterBreeds);
  }

  /// Fetch all cages.
  /// `GET /api/v1/master/cages`
  Future<ApiResponse<dynamic>> getCages() {
    return _client.get(ApiEndpoints.masterCages);
  }

  /// Fetch all colors.
  /// `GET /api/v1/master/colors`
  Future<ApiResponse<dynamic>> getColors() {
    return _client.get(ApiEndpoints.masterColors);
  }

  /// Fetch all diet rules.
  /// `GET /api/v1/master/diet-rules`
  Future<ApiResponse<dynamic>> getDietRules() {
    return _client.get(ApiEndpoints.masterDietRules);
  }

  /// Fetch all medicines.
  /// `GET /api/v1/master/medicines`
  Future<ApiResponse<dynamic>> getMedicines() {
    return _client.get(ApiEndpoints.masterMedicines);
  }

  /// Fetch all treatment rules.
  /// `GET /api/v1/master/treatment-rules`
  Future<ApiResponse<dynamic>> getTreatmentRules() {
    return _client.get(ApiEndpoints.masterTreatmentRules);
  }
}
