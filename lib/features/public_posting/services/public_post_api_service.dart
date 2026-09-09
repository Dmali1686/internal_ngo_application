import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/logger.dart';

/// API service for managing public posts (sharing rescued animals
/// to the public NGO application).
class PublicPostApiService {
  final ApiClient _client = ApiClient();

  // ---------------------------------------------------------------------------
  // Create a new post (DRAFT)
  // POST /api/v1/posts
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> createPost({
    required Map<String, dynamic> body,
  }) {
    AppLogger.info('PublicPostApiService', 'createPost called');
    return _client.post(ApiEndpoints.posts, body: body);
  }

  // ---------------------------------------------------------------------------
  // Publish an existing post
  // POST /api/v1/posts/{id}/publish
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> publishPost(String postId) {
    AppLogger.info('PublicPostApiService', 'publishPost: $postId');
    return _client.post(ApiEndpoints.publishPost(postId));
  }

  // ---------------------------------------------------------------------------
  // Update a post (e.g. edit before publishing)
  // PATCH /api/v1/posts/{id}
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> updatePost({
    required String postId,
    required Map<String, dynamic> updates,
  }) {
    AppLogger.info('PublicPostApiService', 'updatePost: $postId');
    return _client.patch(ApiEndpoints.updatePost(postId), body: updates);
  }

  // ---------------------------------------------------------------------------
  // Upload media (photos) for the post
  // POST /api/v1/media/upload
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> uploadMedia({
    required String filePath,
  }) {
    AppLogger.info('PublicPostApiService', 'uploadMedia: $filePath');
    return _client.uploadFile(
      ApiEndpoints.mediaUpload,
      filePath: filePath,
      fieldName: 'file',
    );
  }
}
