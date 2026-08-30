import 'package:flutter/material.dart';
import '../../../core/utils/app_error_handler.dart';
import '../../../core/utils/logger.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskApiService _apiService = TaskApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TaskModel> _myTasks = [];
  List<TaskModel> get myTasks => _myTasks;

  List<TaskModel> _assignedTasks = [];
  List<TaskModel> get assignedTasks => _assignedTasks;

  List<TaskModel> _allTasks = [];
  List<TaskModel> get allTasks => _allTasks;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchMyTasks({String? departmentId}) async {
    _setLoading(true);
    _setError(null);
    AppLogger.info('TaskProvider', 'fetchMyTasks → starting fetch (departmentId=$departmentId)');
    try {
      _myTasks = await _apiService.getMyTasks(departmentId: departmentId);
      AppLogger.info('TaskProvider', 'fetchMyTasks ← stored ${_myTasks.length} tasks in _myTasks');
      for (final t in _myTasks) {
        AppLogger.info('TaskProvider', '  task: id=${t.id}, title="${t.title}", status=${t.status}, priority=${t.priority}');
      }
    } catch (e) {
      AppLogger.error('TaskProvider', 'fetchMyTasks ← error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAssignedTasks() async {
    _setLoading(true);
    _setError(null);
    try {
      _assignedTasks = await _apiService.getAssignedTasks();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAllTasks() async {
    _setLoading(true);
    _setError(null);
    try {
      _allTasks = await _apiService.getAllTasks();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDepartmentTasks(String departmentId) async {
    // For department details, we can either use 'all tasks' and filter locally or hit the API.
    // If the user is Super Admin, they can get all tasks. We'll filter allTasks locally.
    await fetchAllTasks();
  }

  List<TaskModel> getTasksForDepartment(String departmentId) {
    return _allTasks.where((task) => task.department?.id == departmentId).toList();
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required String priority,
    required String departmentId,
    required String assignedToId,
    String? dueDate,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.createTask(
        title: title,
        description: description,
        priority: priority,
        departmentId: departmentId,
        assignedToId: assignedToId,
        dueDate: dueDate,
      );
      // Refresh relevant lists
      await fetchAssignedTasks();
      await fetchAllTasks();
      return true;
    } catch (e) {
      _setError(AppErrorHandler.translate(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startTask(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.startTask(id);
      await _refreshAfterUpdate();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeTask(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.completeTask(id);
      await _refreshAfterUpdate();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelTask(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.cancelTask(id);
      await _refreshAfterUpdate();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _refreshAfterUpdate() async {
    // Refresh myTasks and assignedTasks for all roles.
    // getAllTasks() is SUP001-only — skip it here to avoid 403 for employees.
    try {
      _myTasks = await _apiService.getMyTasks();
      notifyListeners();
    } catch (e) {
      AppLogger.error('TaskProvider', 'Failed to refresh myTasks after update: $e');
    }
    try {
      _assignedTasks = await _apiService.getAssignedTasks();
      notifyListeners();
    } catch (e) {
      AppLogger.error('TaskProvider', 'Failed to refresh assignedTasks after update: $e');
    }
  }
}
