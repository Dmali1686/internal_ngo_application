import 'package:flutter/material.dart';

/// The four notification categories — each gets distinct visual treatment.
enum NotificationType {
  emergency,
  departmentTask,
  assignedTask,
  general,
}

/// A single notification item.
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;
  final String? link;
  final String? userId;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.link,
    this.userId,
    this.metadata,
  });

  // ── Visual helpers ─────────────────────────────────────────────────────────

  IconData get icon {
    switch (type) {
      case NotificationType.emergency:
        return Icons.warning_amber_rounded;
      case NotificationType.departmentTask:
        return Icons.assignment_rounded;
      case NotificationType.assignedTask:
        return Icons.task_alt_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color get accentColor {
    switch (type) {
      case NotificationType.emergency:
        return const Color(0xFFEF4444);
      case NotificationType.departmentTask:
        return const Color(0xFF2563EB);
      case NotificationType.assignedTask:
        return const Color(0xFF10B981);
      case NotificationType.general:
        return const Color(0xFF64748B);
    }
  }

  Color get iconBgColor {
    switch (type) {
      case NotificationType.emergency:
        return const Color(0xFFFEF2F2);
      case NotificationType.departmentTask:
        return const Color(0xFFEFF6FF);
      case NotificationType.assignedTask:
        return const Color(0xFFECFDF5);
      case NotificationType.general:
        return const Color(0xFFF1F5F9);
    }
  }

  String get typeLabel {
    switch (type) {
      case NotificationType.emergency:
        return 'Emergency';
      case NotificationType.departmentTask:
        return 'Dept Task';
      case NotificationType.assignedTask:
        return 'Assigned';
      case NotificationType.general:
        return 'General';
    }
  }

  // ── Serialisation (for future API integration) ─────────────────────────────

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: _parseType(json['type'] ?? 'general'),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      link: json['link'],
      userId: json['user_id'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      if (link != null) 'link': link,
      if (userId != null) 'user_id': userId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  static NotificationType _parseType(String value) {
    switch (value) {
      case 'emergency':
        return NotificationType.emergency;
      case 'department_task':
      case 'departmentTask':
        return NotificationType.departmentTask;
      case 'assigned_task':
      case 'assignedTask':
        return NotificationType.assignedTask;
      default:
        return NotificationType.general;
    }
  }
}
