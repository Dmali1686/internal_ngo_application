import 'dart:convert';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/diet_models.dart';

/// API service for all diet management endpoints.
///
/// Endpoints:
///   GET  /api/v1/diet/default-plans
///   POST /api/v1/diet/default-plans
///   GET  /api/v1/patients/{id}/diet/history
///   POST /api/v1/patients/{id}/diet/additional
class DietApiService {
  final ApiClient _client = ApiClient();

  // ─────────────────────── Patient Diet History ───────────────────────

  /// Returns all diet records for a patient (DEFAULT + ADDITIONAL).
  /// `GET /api/v1/patients/{id}/diet/history`
  Future<List<PatientDiet>> getDietHistory(String patientId) async {
    AppLogger.info(
        'DietApiService', '📡 GET diet history → patientId=$patientId');
    AppLogger.info(
        'DietApiService', '   Endpoint: ${ApiEndpoints.patientDietHistory(patientId)}');

    try {
      final response =
          await _client.get(ApiEndpoints.patientDietHistory(patientId));

      AppLogger.info(
          'DietApiService', '   Raw response success: ${response.success}');
      AppLogger.info(
          'DietApiService', '   Raw response data type: ${response.data?.runtimeType}');

      if (response.success && response.data != null) {
        // Pretty-print the raw JSON to terminal
        try {
          final prettyJson =
              const JsonEncoder.withIndent('  ').convert(response.data);
          AppLogger.info('DietApiService', '📦 RAW DIET HISTORY RESPONSE:\n$prettyJson');
        } catch (_) {
          AppLogger.info(
              'DietApiService', '📦 Raw data (non-serializable): ${response.data}');
        }

        final List<dynamic> list =
            response.data is List ? response.data as List<dynamic> : [];

        AppLogger.info(
            'DietApiService', '   Parsed ${list.length} diet record(s)');

        final diets = list
            .map((e) => PatientDiet.fromJson(e as Map<String, dynamic>))
            .toList();

        for (var i = 0; i < diets.length; i++) {
          final d = diets[i];
          AppLogger.info(
            'DietApiService',
            '   [${i + 1}] id=${d.id} | source=${d.dietSource} | status=${d.status} | items=${d.items.length}',
          );
          for (var j = 0; j < d.items.length; j++) {
            final item = d.items[j];
            AppLogger.info(
              'DietApiService',
              '       item[${j + 1}] food="${item.foodItem?.name ?? item.foodItemId}" | qty=${item.quantity} | slot=${item.slot}',
            );
          }
        }

        return diets;
      } else {
        AppLogger.error(
            'DietApiService', '❌ getDietHistory failed: ${response.errorMessage}');
        throw Exception(
            response.errorMessage ?? 'Failed to load diet history');
      }
    } catch (e) {
      AppLogger.error('DietApiService', '💥 getDietHistory exception: $e');
      rethrow;
    }
  }

  // ─────────────────────── Additional Diet ───────────────────────

  /// Adds an additional diet to a patient without replacing the existing one.
  /// `POST /api/v1/patients/{id}/diet/additional`
  Future<PatientDiet> addAdditionalDiet(
    String patientId,
    CreateAdditionalDietRequest request,
  ) async {
    AppLogger.info(
        'DietApiService', '📡 POST add additional diet → patientId=$patientId');
    AppLogger.info(
        'DietApiService', '   Endpoint: ${ApiEndpoints.patientDietAdditional(patientId)}');

    try {
      final requestBody = request.toJson();
      try {
        final prettyRequest =
            const JsonEncoder.withIndent('  ').convert(requestBody);
        AppLogger.info('DietApiService', '📤 REQUEST BODY:\n$prettyRequest');
      } catch (_) {
        AppLogger.info('DietApiService', '📤 Request body: $requestBody');
      }

      final response = await _client.post(
        ApiEndpoints.patientDietAdditional(patientId),
        body: requestBody,
      );

      AppLogger.info(
          'DietApiService', '   Raw response success: ${response.success}');

      if (response.success && response.data != null) {
        try {
          final prettyJson =
              const JsonEncoder.withIndent('  ').convert(response.data);
          AppLogger.info(
              'DietApiService', '📦 RAW ADD ADDITIONAL DIET RESPONSE:\n$prettyJson');
        } catch (_) {
          AppLogger.info(
              'DietApiService', '📦 Raw data: ${response.data}');
        }

        final Map<String, dynamic> data =
            response.data is Map
                ? response.data as Map<String, dynamic>
                : {};
        final diet = PatientDiet.fromJson(data);

        AppLogger.info(
            'DietApiService',
            '✅ Additional diet created: id=${diet.id} | source=${diet.dietSource} | status=${diet.status}');
        for (var j = 0; j < diet.items.length; j++) {
          final item = diet.items[j];
          AppLogger.info(
            'DietApiService',
            '   item[${j + 1}] food="${item.foodItem?.name ?? item.foodItemId}" | qty=${item.quantity} | slot=${item.slot}',
          );
        }

        return diet;
      } else {
        AppLogger.error(
            'DietApiService',
            '❌ addAdditionalDiet failed: ${response.errorMessage}');
        throw Exception(
            response.errorMessage ?? 'Failed to add additional diet');
      }
    } catch (e) {
      AppLogger.error('DietApiService', '💥 addAdditionalDiet exception: $e');
      rethrow;
    }
  }

  // ─────────────────────── Default Diet Plans (Admin) ───────────────────────

  /// Returns all default diet plan rules configured by admin.
  /// `GET /api/v1/diet/default-plans`
  Future<List<DefaultDietPlan>> getDefaultDietPlans() async {
    AppLogger.info(
        'DietApiService', '📡 GET default diet plans → ${ApiEndpoints.defaultDietPlans}');

    try {
      final response = await _client.get(ApiEndpoints.defaultDietPlans);

      AppLogger.info(
          'DietApiService', '   Raw response success: ${response.success}');
      AppLogger.info(
          'DietApiService', '   Raw response data type: ${response.data?.runtimeType}');

      if (response.success && response.data != null) {
        try {
          final prettyJson =
              const JsonEncoder.withIndent('  ').convert(response.data);
          AppLogger.info(
              'DietApiService', '📦 RAW DEFAULT DIET PLANS RESPONSE:\n$prettyJson');
        } catch (_) {
          AppLogger.info(
              'DietApiService', '📦 Raw data (non-serializable): ${response.data}');
        }

        final List<dynamic> list =
            response.data is List ? response.data as List<dynamic> : [];

        AppLogger.info(
            'DietApiService', '   Parsed ${list.length} default plan(s)');

        final plans = list
            .map((e) =>
                DefaultDietPlan.fromJson(e as Map<String, dynamic>))
            .toList();

        for (var i = 0; i < plans.length; i++) {
          final p = plans[i];
          AppLogger.info(
            'DietApiService',
            '   [${i + 1}] id=${p.id} | animal=${p.animalType} | condition=${p.condition} | weight=${p.minWeight}–${p.maxWeight}kg | priority=${p.priority} | items=${p.items.length}',
          );
          for (var j = 0; j < p.items.length; j++) {
            final item = p.items[j];
            AppLogger.info(
              'DietApiService',
              '       item[${j + 1}] food="${item.foodItem?.name ?? item.foodItemId}" | qty=${item.quantity} | slot=${item.slot}',
            );
          }
        }

        return plans;
      } else {
        AppLogger.error(
            'DietApiService',
            '❌ getDefaultDietPlans failed: ${response.errorMessage}');
        throw Exception(
            response.errorMessage ?? 'Failed to load default diet plans');
      }
    } catch (e) {
      AppLogger.error(
          'DietApiService', '💥 getDefaultDietPlans exception: $e');
      rethrow;
    }
  }

  /// Creates a new default diet plan rule.
  /// `POST /api/v1/diet/default-plans`
  Future<DefaultDietPlan> createDefaultDietPlan(
    CreateDefaultDietPlanRequest request,
  ) async {
    AppLogger.info(
        'DietApiService', '📡 POST create default diet plan → ${ApiEndpoints.defaultDietPlans}');

    try {
      final requestBody = request.toJson();
      try {
        final prettyRequest =
            const JsonEncoder.withIndent('  ').convert(requestBody);
        AppLogger.info('DietApiService', '📤 REQUEST BODY:\n$prettyRequest');
      } catch (_) {
        AppLogger.info('DietApiService', '📤 Request body: $requestBody');
      }

      final response = await _client.post(
        ApiEndpoints.defaultDietPlans,
        body: requestBody,
      );

      AppLogger.info(
          'DietApiService', '   Raw response success: ${response.success}');

      if (response.success && response.data != null) {
        try {
          final prettyJson =
              const JsonEncoder.withIndent('  ').convert(response.data);
          AppLogger.info(
              'DietApiService',
              '📦 RAW CREATE DEFAULT PLAN RESPONSE:\n$prettyJson');
        } catch (_) {
          AppLogger.info('DietApiService', '📦 Raw data: ${response.data}');
        }

        final Map<String, dynamic> data =
            response.data is Map
                ? response.data as Map<String, dynamic>
                : {};
        final plan = DefaultDietPlan.fromJson(data);

        AppLogger.info(
            'DietApiService',
            '✅ Default plan created: id=${plan.id} | animal=${plan.animalType} | condition=${plan.condition} | items=${plan.items.length}');

        return plan;
      } else {
        AppLogger.error(
            'DietApiService',
            '❌ createDefaultDietPlan failed: ${response.errorMessage}');
        throw Exception(
            response.errorMessage ?? 'Failed to create default diet plan');
      }
    } catch (e) {
      AppLogger.error(
          'DietApiService', '💥 createDefaultDietPlan exception: $e');
      rethrow;
    }
  }
}
