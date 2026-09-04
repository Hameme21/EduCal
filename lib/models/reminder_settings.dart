import 'package:flutter/material.dart';

class ReminderSettings {
  final TimeOfDay holidayReminderTime; // Default: 8:00 AM
  final int classReminderMinutesBefore; // Default: 10 minutes
  final TimeOfDay normalEventReminderTime; // Default: 10:00 PM (22:00)
  final bool normalEventRemindDayBefore; // Default: true (day before)
  final bool enableHolidayReminders;
  final bool enableClassReminders;
  final bool enableNormalEventReminders;

  const ReminderSettings({
    this.holidayReminderTime = const TimeOfDay(hour: 8, minute: 0),
    this.classReminderMinutesBefore = 10,
    this.normalEventReminderTime = const TimeOfDay(hour: 22, minute: 0),
    this.normalEventRemindDayBefore = true,
    this.enableHolidayReminders = true,
    this.enableClassReminders = true,
    this.enableNormalEventReminders = true,
  });

  ReminderSettings copyWith({
    TimeOfDay? holidayReminderTime,
    int? classReminderMinutesBefore,
    TimeOfDay? normalEventReminderTime,
    bool? normalEventRemindDayBefore,
    bool? enableHolidayReminders,
    bool? enableClassReminders,
    bool? enableNormalEventReminders,
  }) {
    return ReminderSettings(
      holidayReminderTime: holidayReminderTime ?? this.holidayReminderTime,
      classReminderMinutesBefore: classReminderMinutesBefore ?? this.classReminderMinutesBefore,
      normalEventReminderTime: normalEventReminderTime ?? this.normalEventReminderTime,
      normalEventRemindDayBefore: normalEventRemindDayBefore ?? this.normalEventRemindDayBefore,
      enableHolidayReminders: enableHolidayReminders ?? this.enableHolidayReminders,
      enableClassReminders: enableClassReminders ?? this.enableClassReminders,
      enableNormalEventReminders: enableNormalEventReminders ?? this.enableNormalEventReminders,
    );
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
