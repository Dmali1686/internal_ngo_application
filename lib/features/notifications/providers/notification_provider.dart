import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/notification_model.dart';

/// Manages notification state across the app.
///
/// The [onNewNotification] callback is set by [NotificationPopupOverlay]
/// so it can show a toast whenever a notification is added.
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  /// The most recent notification that should trigger a popup toast.
  /// The overlay reads this, shows the popup, then calls [clearLatestPopup].
  NotificationModel? _latestPopup;
  NotificationModel? get latestPopup => _latestPopup;

  /// Selected filter type (null = All).
  NotificationType? _selectedFilter;
  NotificationType? get selectedFilter => _selectedFilter;

  final FlutterTts _tts = FlutterTts();

  /// Set to `true` to auto-fire a demo popup 5 seconds after launch.
  /// Turn off once done testing.
  static const bool _enableDemoPopup = true;

  NotificationProvider() {
    _initTts();
    _seedMockData();
    if (_enableDemoPopup) _scheduleDemoPopup();
  }

  void _scheduleDemoPopup() {
    Future.delayed(const Duration(seconds: 5), () {
      addNotification(NotificationModel(
        id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.emergency,
        title: 'Rescue SOS — Sector 14',
        message: 'Injured stray dog reported near Highway NH-48. Ambulance dispatched. Immediate vet attention needed.',
        createdAt: DateTime.now(),
      ));
    });
    // Second popup (different type) fires at 12 seconds
    Future.delayed(const Duration(seconds: 12), () {
      addNotification(NotificationModel(
        id: 'demo2_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.assignedTask,
        title: 'New Task: Evening Medication Round',
        message: 'Dr. Sharma assigned you to administer medication for Ward B patients by 7 PM.',
        createdAt: DateTime.now(),
      ));
    });
    // Third popup (department task) at 20 seconds
    Future.delayed(const Duration(seconds: 20), () {
      addNotification(NotificationModel(
        id: 'demo3_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.departmentTask,
        title: 'Kitchen Alert: Special Diet',
        message: 'Prepare hypoallergenic meals for 5 new patients admitted today. Check diet dashboard.',
        createdAt: DateTime.now(),
      ));
    });
  }

  // ── TTS setup ──────────────────────────────────────────────────────────────

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);
  }

  // ── Public getters ─────────────────────────────────────────────────────────

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get filteredNotifications {
    if (_selectedFilter == null) return _notifications;
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  /// Group notifications by day for the notification center.
  Map<String, List<NotificationModel>> get groupedNotifications {
    final map = <String, List<NotificationModel>>{};
    final now = DateTime.now();
    for (final n in filteredNotifications) {
      String label;
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day))
          .inDays;
      if (diff == 0) {
        label = 'Today';
      } else if (diff == 1) {
        label = 'Yesterday';
      } else {
        label =
            '${_monthName(n.createdAt.month)} ${n.createdAt.day}, ${n.createdAt.year}';
      }
      map.putIfAbsent(label, () => []).add(n);
    }
    return map;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void setFilter(NotificationType? type) {
    _selectedFilter = type;
    notifyListeners();
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void clearLatestPopup() {
    _latestPopup = null;
    // No notifyListeners here — the overlay already consumed it.
  }

  /// Adds a new notification and triggers the popup + sound/haptics.
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _latestPopup = notification;
    _playNotificationFeedback(notification.type);
    notifyListeners();
  }

  /// Removes a single notification.
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Clears all notifications.
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // ── Sound & Haptics ────────────────────────────────────────────────────────

  Future<void> _playNotificationFeedback(NotificationType type) async {
    switch (type) {
      case NotificationType.emergency:
        // Heavy haptic + spoken alert for emergencies
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        HapticFeedback.heavyImpact();
        await _tts.speak('Emergency Alert');
        break;
      case NotificationType.departmentTask:
      case NotificationType.assignedTask:
        HapticFeedback.mediumImpact();
        break;
      case NotificationType.general:
        HapticFeedback.lightImpact();
        break;
    }
  }

  // ── Mock data ──────────────────────────────────────────────────────────────

  void _seedMockData() {
    final now = DateTime.now();
    _notifications = [
      NotificationModel(
        id: 'n1',
        type: NotificationType.emergency,
        title: 'Critical Animal Arrived',
        message:
            'A severely injured dog has been brought to the emergency ward. Immediate veterinary attention required in Ward A.',
        createdAt: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.assignedTask,
        title: 'New Task Assigned to You',
        message:
            'Dr. Mehta has assigned you: "Administer medication to Patient ANM-0234 (Buddy)" — due by 6:00 PM today.',
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.departmentTask,
        title: 'Food Preparation Required',
        message:
            'Special diet meals for 12 animals need to be prepared by 6:00 PM today. Check the kitchen dashboard for details.',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.general,
        title: 'Diet Plan Updated',
        message:
            'The default diet plan for Large Dogs has been updated with new nutritional guidelines.',
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      NotificationModel(
        id: 'n5',
        type: NotificationType.emergency,
        title: 'Rescue SOS Alert',
        message:
            'Emergency rescue request received from Sector 22. Injured cow found near the highway. Ambulance dispatched.',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      NotificationModel(
        id: 'n6',
        type: NotificationType.departmentTask,
        title: 'Ward C Deep Cleaning',
        message:
            'Deep cleaning has been scheduled for Ward C today. Cleaning supplies have been restocked in the storage room.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: 'n7',
        type: NotificationType.assignedTask,
        title: 'Task Completed',
        message:
            'Your task "Morning rounds for Ward B" has been marked as completed by the system.',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        isRead: true,
      ),
      NotificationModel(
        id: 'n8',
        type: NotificationType.general,
        title: 'System Maintenance',
        message:
            'The QR management system will undergo maintenance tonight from 2:00 AM to 4:00 AM. Plan accordingly.',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
