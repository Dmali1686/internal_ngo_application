import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/task_model.dart';

class TaskApiService {
  final ApiClient _apiClient;

  TaskApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all tasks (SUP001 only)
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final response = await _apiClient.get('/tasks');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['tasks'] ?? [];
        return data.map((e) => TaskModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to get all tasks: $e');
      rethrow;
    }
  }

  /// Get tasks assigned BY the logged-in user (SUP001, ADM001)
  Future<List<TaskModel>> getAssignedTasks() async {
    try {
      final response = await _apiClient.get('/tasks/assigned');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['tasks'] ?? [];
        return data.map((e) => TaskModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to get assigned tasks: $e');
      rethrow;
    }
  }

  /// Get tasks assigned TO the logged-in user (EMP001, etc.)
  Future<List<TaskModel>> getMyTasks({String? departmentId}) async {
    try {
      final queryParams = departmentId != null ? {'department_id': departmentId} : null;
      AppLogger.info('TaskApiService', 'getMyTasks → calling GET /tasks/my (departmentId=$departmentId)');
      final response = await _apiClient.get('/tasks/my', queryParameters: queryParams);
      AppLogger.info('TaskApiService', 'getMyTasks ← statusCode=${response.statusCode}');
      AppLogger.info('TaskApiService', 'getMyTasks ← raw data=${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['tasks'] ?? [];
        AppLogger.info('TaskApiService', 'getMyTasks ← parsed ${data.length} tasks from response');
        final tasks = data.map((e) => TaskModel.fromJson(e)).toList();
        return tasks;
      }
      AppLogger.error('TaskApiService', 'getMyTasks ← non-200 or null data, returning empty list');
      return [];
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to get my tasks: $e');
      rethrow;
    }
  }


  /// Get a single task by ID
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final response = await _apiClient.get('/tasks/$id');
      if (response.statusCode == 200 && response.data != null) {
        return TaskModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to get task $id: $e');
      rethrow;
    }
  }

  /// Create a new task
  Future<void> createTask({
    required String title,
    required String description,
    required String priority,
    required String departmentId,
    required String assignedToId,
    String? dueDate,
  }) async {
    try {
      final body = {
        'title': title,
        'description': description,
        'priority': priority,
        'department_id': departmentId,
        'assigned_to': assignedToId,
        'task_type': 'ONE_TIME',
        if (dueDate != null) 'due_date': dueDate,
      };
      
      final response = await _apiClient.post('/tasks', body: body);
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create task, status code: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to create task: $e');
      rethrow;
    }
  }

  /// Start a task
  Future<void> startTask(String id) async {
    try {
      final response = await _apiClient.patch('/tasks/$id/start');
      if (response.statusCode != 200) {
        throw Exception('Failed to start task, status code: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to start task $id: $e');
      rethrow;
    }
  }

  /// Complete a task
  Future<void> completeTask(String id) async {
    try {
      final response = await _apiClient.patch('/tasks/$id/complete');
      if (response.statusCode != 200) {
        throw Exception('Failed to complete task, status code: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to complete task $id: $e');
      rethrow;
    }
  }

  /// Cancel a task
  Future<void> cancelTask(String id) async {
    try {
      final response = await _apiClient.patch('/tasks/$id/cancel');
      if (response.statusCode != 200) {
        throw Exception('Failed to cancel task, status code: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to cancel task $id: $e');
      rethrow;
    }
  }
}
