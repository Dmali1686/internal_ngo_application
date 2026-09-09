import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../models/food_dept_models.dart';
import '../services/food_dept_api_service.dart';

/// State provider for the Food Department feeding schedule screen.
///
/// Manages:
///  - Loading state
///  - The [DailyScheduleResponse] from the backend
///  - Currently selected date (defaults to today)
///  - Slot filter (null = all slots)
///  - Per-task completing state (to disable button while PATCH is in flight)
class FoodDeptProvider extends ChangeNotifier {
  final FoodDeptApiService _apiService = FoodDeptApiService();

  // ─── Loading & Error ───
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Schedule Data ───
  DailyScheduleResponse? _schedule;
  DailyScheduleResponse? get schedule => _schedule;

  // ─── Selected Date ───
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  String get selectedDateFormatted {
    final d = _selectedDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  // ─── Slot Filter (null = show all) ───
  String? _selectedSlot; // "MORNING" | "AFTERNOON" | "EVENING" | null
  String? get selectedSlot => _selectedSlot;

  // ─── History mode ───
  bool _showHistory = false;
  bool get showHistory => _showHistory;

  void setSlotFilter(String? slot) {
    _selectedSlot = slot;
    _showHistory = false; // leave history mode when a slot pill is tapped
    notifyListeners();
  }

  void toggleHistory() {
    _showHistory = !_showHistory;
    if (_showHistory) _selectedSlot = null; // clear slot filter in history mode
    notifyListeners();
  }

  // ─── Tasks being completed (set of taskIds) ───
  final Set<String> _completingTasks = {};
  bool isCompleting(String taskId) => _completingTasks.contains(taskId);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ─── Fetch Schedule ───

  /// Loads today's schedule.
  Future<void> fetchTodaySchedule() async {
    _selectedDate = DateTime.now();
    await _loadSchedule();
  }

  /// Loads the schedule for the given [date].
  Future<void> fetchScheduleForDate(DateTime date) async {
    _selectedDate = date;
    await _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    _setLoading(true);
    _setError(null);
    AppLogger.info(
        'FoodDeptProvider', 'fetchSchedule → date=$selectedDateFormatted');
    try {
      if (isToday) {
        _schedule = await _apiService.getTodaySchedule();
      } else {
        _schedule = await _apiService.getScheduleByDate(selectedDateFormatted);
      }
      AppLogger.info(
          'FoodDeptProvider',
          'fetchSchedule ← ${_schedule?.totalTasks ?? 0} tasks, '
          '${_schedule?.schedule.length ?? 0} patients');
    } catch (e) {
      AppLogger.error('FoodDeptProvider', 'fetchSchedule error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ─── Complete a feeding task ───

  /// Marks the task with [taskId] as completed.
  /// Returns `true` on success, `false` on error.
  Future<bool> completeTask(String taskId, {String? notes}) async {
    _completingTasks.add(taskId);
    notifyListeners();

    AppLogger.info('FoodDeptProvider', 'completeTask → taskId=$taskId');

    try {
      await _apiService.completeTask(taskId, notes: notes);
      AppLogger.info('FoodDeptProvider', 'completeTask ✅ taskId=$taskId');

      // Refresh the schedule to reflect the completed task.
      await _loadSchedule();
      return true;
    } catch (e) {
      AppLogger.error('FoodDeptProvider', 'completeTask error: $e');
      _setError(e.toString());
      _completingTasks.remove(taskId);
      notifyListeners();
      return false;
    }
  }

  // ─── Filtered schedule patients ───

  /// Returns the [PatientSchedule] list filtered by the selected slot.
  /// Patients whose every task is completed are hidden from the list
  /// (the completed count in the summary bar is unaffected — it comes
  /// directly from the backend's [DailyScheduleResponse.completedTasks]).
  List<PatientSchedule> get filteredPatients {
    final patients = _schedule?.schedule ?? [];

    // Keep only patients that still have at least one PENDING task
    // (optionally also matching the selected slot filter).
    return patients.where((p) {
      final slotsToCheck = _selectedSlot == null
          ? p.slots
          : p.slots.where((s) => s.slot == _selectedSlot).toList();
      return slotsToCheck.any((s) => s.items.any((t) => t.isPending));
    }).toList();
  }

  /// For a given patient, returns only the slot(s) that match the filter
  /// AND still have at least one pending task (completed tasks are hidden).
  List<SlotSchedule> visibleSlotsFor(PatientSchedule patient) {
    final slots = _selectedSlot == null
        ? patient.slots
        : patient.slots.where((s) => s.slot == _selectedSlot).toList();

    // Within each slot, strip out completed tasks so done cards disappear.
    return slots
        .map((s) => SlotSchedule(
              slot: s.slot,
              items: s.items.where((t) => t.isPending).toList(),
            ))
        .where((s) => s.items.isNotEmpty) // drop slots that become empty
        .toList();
  }

  // ─── Completed history (frontend-only, no extra API call) ───

  /// Returns a flat list of [_CompletedEntry] records built from the already-
  /// fetched schedule data.  No backend round-trip is needed.
  List<CompletedEntry> get completedHistory {
    final result = <CompletedEntry>[];
    for (final patient in _schedule?.schedule ?? []) {
      for (final slot in patient.slots) {
        for (final task in slot.items) {
          if (task.isCompleted) {
            result.add(CompletedEntry(
              patient: patient,
              slot: slot.slot,
              task: task,
            ));
          }
        }
      }
    }
    return result;
  }
}

/// Holds one completed feeding task together with its patient context.
class CompletedEntry {
  final PatientSchedule patient;
  final String slot; // "MORNING" | "AFTERNOON" | "EVENING"
  final FeedingTask task;

  const CompletedEntry({
    required this.patient,
    required this.slot,
    required this.task,
  });
}
