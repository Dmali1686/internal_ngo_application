import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/task_model.dart';


class TaskApiService {
  final ApiClient _apiClient;
  // Temporary cache for dept id/code during flat-format fallback grouping
  final Map<String, ({String id, String code})> _deptMeta = {};

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

  /// Get tasks assigned TO the logged-in user — grouped by department.
  ///
  /// Returns a [MyTasksGroupedResponse] with a list of department buckets.
  Future<MyTasksGroupedResponse> getMyTasksGrouped() async {
    try {
      AppLogger.info('TaskApiService', 'getMyTasksGrouped → GET /tasks/my');
      final response = await _apiClient.get('/tasks/my');
      AppLogger.info('TaskApiService', 'getMyTasksGrouped ← statusCode=${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        // New grouped format: { "departments": [...] }
        if (response.data is Map && response.data['departments'] != null) {
          final result = MyTasksGroupedResponse.fromJson(
              response.data as Map<String, dynamic>);
          AppLogger.info('TaskApiService',
              'getMyTasksGrouped ← ${result.departments.length} dept groups, ${result.allTasks.length} total tasks');
          return result;
        }
        // Fallback: old flat format { "tasks": [...] }
        // Group by the task's own department name instead of hardcoding 'My Tasks'
        final List<dynamic> data = response.data['tasks'] ?? [];
        final tasks = data.map((e) => TaskModel.fromJson(e)).toList();

        // Group by actual department
        final Map<String, List<TaskModel>> byDept = {};
        for (final t in tasks) {
          final deptName = t.department?.name ?? 'General';
          final deptId   = t.department?.id   ?? '';
          final deptCode = t.department?.code  ?? '';
          byDept.putIfAbsent(deptName, () => []).add(t);
          // store id/code on first encounter (used below)
          _deptMeta[deptName] = (id: deptId, code: deptCode);
        }

        final groups = byDept.entries.map((e) {
          final meta = _deptMeta[e.key] ?? (id: '', code: '');
          return DepartmentTaskGroup(
            departmentId:   meta.id,
            departmentCode: meta.code,
            departmentName: e.key,
            tasks: e.value,
          );
        }).toList();

        return MyTasksGroupedResponse(departments: groups);
      }
      return const MyTasksGroupedResponse(departments: []);
    } catch (e) {
      AppLogger.error('TaskApiService', 'Failed to get my tasks: $e');
      rethrow;
    }
  }

  /// Legacy flat list — kept for backwards compat.
  Future<List<TaskModel>> getMyTasks({String? departmentId}) async {
    try {
      final grouped = await getMyTasksGrouped();
      if (departmentId != null) {
        final dept = grouped.departments
            .where((d) => d.departmentId == departmentId)
            .toList();
        return dept.isEmpty ? [] : dept.first.tasks;
      }
      return grouped.allTasks;
    } catch (e) {
      AppLogger.error('TaskApiService', 'getMyTasks (flat) failed: $e');
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
