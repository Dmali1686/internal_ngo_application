import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// API service responsible for fetching the list of dashboard modules
/// allowed for the currently authenticated user's role.
///
/// Endpoint: `GET /api/v1/auth/me/modules`
///
/// On success the backend returns:
/// ```json
/// {
///   "role": "doctor",
///   "modules": [
///     { "key": "treatment_cycle", "title": "Treatment Cycle",
///       "subtitle": "Manage treatment and recovery", "route": "/treatment-dashboard" }
///   ]
/// }
/// ```
class DashboardModulesApiService {
  final ApiClient _client = ApiClient();

  /// Fetch the modules the current user is allowed to see.
  ///
  /// Returns a raw [ApiResponse] so the caller (Provider) can decide
  /// how to handle success / failure gracefully.
  Future<ApiResponse<dynamic>> getModules() async {
    return _client.get(ApiEndpoints.myModules);
  }
}
