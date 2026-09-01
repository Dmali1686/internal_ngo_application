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

  /// Grouped my-tasks response from the new API.
  MyTasksGroupedResponse? _myTasksGrouped;
  MyTasksGroupedResponse? get myTasksGrouped => _myTasksGrouped;

  /// Currently selected department filter (null = show all).
  String? _selectedDepartmentFilter;
  String? get selectedDepartmentFilter => _selectedDepartmentFilter;

  void setDepartmentFilter(String? departmentId) {
    _selectedDepartmentFilter = departmentId;
    notifyListeners();
  }

  /// Returns tasks for the currently selected department filter.
  /// If null, returns all tasks across all departments.
  List<TaskModel> get filteredMyTasks {
    if (_myTasksGrouped == null) return _myTasks;
    if (_selectedDepartmentFilter == null) return _myTasksGrouped!.allTasks;
    final dept = _myTasksGrouped!.departments
        .where((d) => d.departmentId == _selectedDepartmentFilter)
        .toList();
    return dept.isEmpty ? [] : dept.first.tasks;
  }

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
    AppLogger.info('TaskProvider', 'fetchMyTasks → starting grouped fetch');
    try {
      _myTasksGrouped = await _apiService.getMyTasksGrouped();
      _myTasks = _myTasksGrouped!.allTasks;
      AppLogger.info('TaskProvider',
          'fetchMyTasks ← ${_myTasksGrouped!.departments.length} departments, ${_myTasks.length} total tasks');
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
    try {
      await fetchAllTasks();
    } catch (_) {
      // If fetchAllTasks fails (e.g., Admin 403), fallback to assigned tasks
    }
    try {
      await fetchAssignedTasks();
    } catch (_) {}
  }

  List<TaskModel> getTasksForDepartment(String departmentId) {
    if (_allTasks.isNotEmpty) {
      return _allTasks.where((task) => task.department?.id == departmentId).toList();
    }
    // Fallback to assigned tasks if allTasks failed or we are admin
    return _assignedTasks.where((task) => task.department?.id == departmentId).toList();
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
