import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

/// API service for rescue reports and rescue trips (internal).
///
/// All methods use [ApiClient] which automatically prepends
/// the base URL (`http://192.168.1.35:8080/api/v1`).
class RescueApiService {
  final ApiClient _client = ApiClient();

  // ---------------------------------------------------------------------------
  // Rescue Reports
  // ---------------------------------------------------------------------------

  /// List all rescue reports, optionally filtered by status.
  /// `GET /api/v1/rescue-reports`
  Future<ApiResponse<dynamic>> listRescueReports({String? status}) {
    return _client.get(
      ApiEndpoints.rescueReports,
      queryParameters: status != null ? {'status': status} : null,
    );
  }

  /// Get detailed info of a specific rescue report.
  /// `GET /api/v1/rescue-reports/{id}`
  Future<ApiResponse<dynamic>> getRescueReportDetail(String reportId) {
    return _client.get(ApiEndpoints.rescueReportDetail(reportId));
  }

  /// Update the status of a rescue report.
  /// `PATCH /api/v1/rescue-reports/{id}`
  Future<ApiResponse<dynamic>> updateRescueReport({
    required String reportId,
    required Map<String, dynamic> updates,
  }) {
    return _client.patch(
      ApiEndpoints.rescueReportDetail(reportId),
      body: updates,
    );
  }

  // ---------------------------------------------------------------------------
  // Rescue Trips
  // ---------------------------------------------------------------------------

  /// List all rescue trips.
  /// `GET /api/v1/rescue-trips`
  Future<ApiResponse<dynamic>> listRescueTrips() {
    return _client.get(ApiEndpoints.rescueTrips);
  }

  /// Create (dispatch) a rescue trip.
  /// `POST /api/v1/rescue-trips`
  Future<ApiResponse<dynamic>> createRescueTrip({
    required Map<String, dynamic> tripData,
  }) {
    return _client.post(ApiEndpoints.rescueTrips, body: tripData);
  }

  /// Get details of a specific rescue trip.
  /// `GET /api/v1/rescue-trips/{id}`
  Future<ApiResponse<dynamic>> getRescueTripDetail(String tripId) {
    return _client.get(ApiEndpoints.rescueTripDetail(tripId));
  }

  /// Update a rescue trip (e.g., status update).
  /// `PATCH /api/v1/rescue-trips/{id}`
  Future<ApiResponse<dynamic>> updateRescueTrip({
    required String tripId,
    required Map<String, dynamic> updates,
  }) {
    return _client.patch(ApiEndpoints.rescueTripDetail(tripId), body: updates);
  }
}
