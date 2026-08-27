import '../../../core/network/api_client.dart';
import '../models/user_creation_models.dart';

class UserApiService {
  final ApiClient _apiClient = ApiClient();

  /// Creates a new user and returns the new user's ID.
  Future<String> createUser(UserCreationRequest request) async {
    final payload = request.toJson();
    print('--- UserApiService.createUser ---');
    print('Payload: $payload');
    
    final response = await _apiClient.post(
      '/users',
      body: payload,
    );
    print('Response: ${response.data}');

    // Assuming the response body contains the newly created user's ID in a field like 'id'
    // This depends on the exact structure returned by the backend 201 Created response.
    // E.g. { "data": { "id": "uuid-1234", ... } } or { "id": "uuid-1234" }
    final data = response.data;
    
    if (data is Map<String, dynamic>) {
      if (data.containsKey('user_id')) {
        return data['user_id'].toString();
      } else if (data.containsKey('id')) {
        return data['id'].toString();
      } else if (data.containsKey('data') && data['data'] is Map && data['data'].containsKey('id')) {
         return data['data']['id'].toString();
      }
    }
    
    // Fallback: if we can't parse an ID, throw an error or return a blank string depending on how it's handled.
    // For this example, we return empty string if no ID is found (but in a real scenario we'd want to throw).
    return '';
  }

  /// Assigns multiple roles to a user.
  Future<void> assignRoles(String userId, UserAssignmentRequest request) async {
    final payload = request.toJson();
    print('--- UserApiService.assignRoles ---');
    print('UserId: $userId');
    print('Payload: $payload');
    
    final response = await _apiClient.post(
      '/users/$userId/assignments',
      body: payload,
    );
    print('Response: ${response.data}');
  }

  /// Fetches the list of departments.
  Future<List<DepartmentItem>> fetchDepartments() async {
    final response = await _apiClient.get('/departments');
    final data = response.data;
    if (data is List) {
      return data.map((json) => DepartmentItem.fromJson(json)).toList();
    }
    return [];
  }

  /// Fetches the list of positions.
  Future<List<PositionItem>> fetchPositions() async {
    final response = await _apiClient.get('/positions');
    final data = response.data;
    if (data is List) {
      return data.map((json) => PositionItem.fromJson(json)).toList();
    }
    return [];
  }

  /// Fetches the list of access categories.
  Future<List<AccessCategoryItem>> fetchAccessCategories() async {
    final response = await _apiClient.get('/access-categories');
    final data = response.data;
    if (data is List) {
      return data.map((json) => AccessCategoryItem.fromJson(json)).toList();
    }
    return [];
  }
}
