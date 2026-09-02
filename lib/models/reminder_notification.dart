import 'package:flutter/material.dart';

enum NotificationType {
  classReminder,
  feeReminder,
  holidayAlert,
  examReminder,
  generalNotice,
}

class ReminderNotification {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledFor;
  final NotificationType type;
  final String? relatedId;
  final bool isMutedDueToHoliday;
  bool isRead;
  final DateTime createdAt;

  ReminderNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledFor,
    required this.type,
    this.relatedId,
    this.isMutedDueToHoliday = false,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  IconData get icon {
    switch (type) {
      case NotificationType.classReminder:
        return Icons.class_outlined;
      case NotificationType.feeReminder:
        return Icons.payment_rounded;
      case NotificationType.holidayAlert:
        return Icons.celebration_rounded;
      case NotificationType.examReminder:
        return Icons.edit_calendar_rounded;
      case NotificationType.generalNotice:
        return Icons.notifications_active_rounded;
    }
  }

  Color get color {
    if (isMutedDueToHoliday) return Colors.grey;
    switch (type) {
      case NotificationType.classReminder:
        return const Color(0xFF1976D2);
      case NotificationType.feeReminder:
        return const Color(0xFFF57C00);
      case NotificationType.holidayAlert:
        return const Color(0xFFD32F2F);
      case NotificationType.examReminder:
        return const Color(0xFF7B1FA2);
      case NotificationType.generalNotice:
        return const Color(0xFF00796B);
    }
  }
}
