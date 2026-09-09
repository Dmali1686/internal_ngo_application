import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';

class NotificationService {
  final ApiClient _client = ApiClient();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request permissions, get FCM token and register with backend
  Future<void> initializeAndRegisterToken() async {
    try {
      // 1. Request permissions (especially for iOS)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        AppLogger.info('NotificationService', 'User declined or has not accepted push permissions');
        return;
      }

      // 2. Get device token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _registerTokenWithBackend(token);
      }

      // 3. Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        _registerTokenWithBackend(newToken);
      });
    } catch (e) {
      AppLogger.error('NotificationService', 'Failed to initialize FCM: $e');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      String platform = 'web';
      if (Platform.isAndroid) platform = 'android';
      if (Platform.isIOS) platform = 'ios';

      await _client.post(
        ApiEndpoints.notificationsToken,
        body: {
          'fcm_token': token,
          'platform': platform,
        },
      );
      AppLogger.info('NotificationService', 'Registered FCM token for $platform');
    } catch (e) {
      AppLogger.error('NotificationService', 'Failed to register token: $e');
    }
  }

  /// Fetch inbox with pagination
  Future<List<dynamic>> fetchInbox({int limit = 20, int offset = 0}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.notificationsInbox,
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );
      if (response.success && response.data is List) {
        return response.data as List;
      }
      return [];
    } catch (e) {
      AppLogger.error('NotificationService', 'Failed to fetch inbox: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String id) async {
    try {
      final response = await _client.put(ApiEndpoints.notificationsInboxMarkRead(id));
      return response.success;
    } catch (e) {
      AppLogger.error('NotificationService', 'Failed to mark as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String id) async {
    try {
      final response = await _client.delete(ApiEndpoints.notificationsInboxDelete(id));
      return response.success;
    } catch (e) {
      AppLogger.error('NotificationService', 'Failed to delete notification: $e');
      return false;
    }
  }
}
