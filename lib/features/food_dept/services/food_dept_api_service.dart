import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/food_dept_models.dart';

/// API service for all Food Department endpoints.
///
/// The backend always wraps responses in:
///   `{ "success": true, "data": { ... } }`
///
/// This service unwraps that outer envelope before calling fromJson.
class FoodDeptApiService {
  final ApiClient _client = ApiClient();

  // ─────────────────────────────────────── helpers ───────────────────────────

  /// Unwrap the outer `{ "success": ..., "data": { ... } }` envelope.
  ///
  /// If `response.data` already IS the inner model (no `data` key),
  /// returns it as-is (fallback for future backend changes).
  Map<String, dynamic> _unwrap(dynamic responseData) {
    if (responseData is! Map) return {};
    final outer = responseData as Map<String, dynamic>;
    // Backend wraps payload inside a "data" key.
    if (outer.containsKey('data') && outer['data'] is Map) {
      return outer['data'] as Map<String, dynamic>;
    }
    // Already unwrapped (e.g. some endpoints return the model directly).
    return outer;
  }

  // ─────────────────── Get Today's Schedule ────────────────────────────────

  /// Returns the feeding schedule for today.
  /// `GET /api/v1/food-dept/schedule/today`
  Future<DailyScheduleResponse> getTodaySchedule() async {
    AppLogger.info('FoodDeptApiService', '📡 GET food-dept schedule → today');
    try {
      final response = await _client.get(ApiEndpoints.foodDeptScheduleToday);

      AppLogger.info(
          'FoodDeptApiService', '   status: ${response.success}');

      if (response.success && response.data != null) {
        // Log the raw outer envelope for debugging.
        try {
          final prettyJson =
              const JsonEncoder.withIndent('  ').convert(response.data);
          AppLogger.info(
              'FoodDeptApiService', '📦 RAW (outer):\n$prettyJson');
        } catch (_) {}

        final inner = _unwrap(response.data);

        AppLogger.info('FoodDeptApiService',
            '📦 INNER keys: ${inner.keys.toList()}');
        AppLogger.info('FoodDeptApiService',
            '   schedule entries: ${(inner["schedule"] as List?)?.length ?? 0}');

        return DailyScheduleResponse.fromJson(inner);
      } else {
        AppLogger.error(
            'FoodDeptApiService',
            '❌ getTodaySchedule failed: ${response.errorMessage}');
        throw Exception(
            response.errorMessage ?? 'Failed to load today\'s schedule');
      }
    } catch (e) {
      AppLogger.error(
          'FoodDeptApiService', '💥 getTodaySchedule exception: $e');
      rethrow;
    }
  }

  // ─────────────────── Get Schedule by Date ───────────────────────────────

  /// Returns the feeding schedule for a specific date (`YYYY-MM-DD`).
  /// `GET /api/v1/food-dept/schedule/{date}`
  Future<DailyScheduleResponse> getScheduleByDate(String date) async {
    AppLogger.info(
        'FoodDeptApiService', '📡 GET food-dept schedule → date=$date');
    try {
      final response =
          await _client.get(ApiEndpoints.foodDeptScheduleByDate(date));

      if (response.success && response.data != null) {
        final inner = _unwrap(response.data);
        return DailyScheduleResponse.fromJson(inner);
      } else {
        throw Exception(
            response.errorMessage ?? 'Failed to load schedule for $date');
      }
    } catch (e) {
      AppLogger.error(
          'FoodDeptApiService', '💥 getScheduleByDate exception: $e');
      rethrow;
    }
  }

  // ─────────────────── Complete Task ──────────────────────────────────────

  /// Marks a feeding task as completed.
  /// `PATCH /api/v1/food-dept/tasks/{taskId}/complete`
  Future<CompleteTaskResponse> completeTask(String taskId,
      {String? notes}) async {
    AppLogger.info(
        'FoodDeptApiService', '📡 PATCH complete task → taskId=$taskId');

    try {
      final body = notes != null && notes.trim().isNotEmpty
          ? <String, dynamic>{'notes': notes.trim()}
          : <String, dynamic>{};

      final response = await _client.patch(
        ApiEndpoints.foodDeptCompleteTask(taskId),
        body: body.isEmpty ? null : body,
      );

      if (response.success && response.data != null) {
        final inner = _unwrap(response.data);
        return CompleteTaskResponse.fromJson(inner);
      } else {
        throw Exception(
            response.errorMessage ?? 'Failed to complete feeding task');
      }
    } catch (e) {
      AppLogger.error('FoodDeptApiService', '💥 completeTask exception: $e');
      rethrow;
    }
  }
}
