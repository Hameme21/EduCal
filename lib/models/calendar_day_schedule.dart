import 'class_schedule.dart';
import 'academic_notice.dart';

class CalendarDaySchedule {
  final DateTime date;
  final bool isHoliday;
  final List<AcademicNotice> holidayNotices;
  final List<AcademicNotice> otherNotices;
  final List<ClassSchedule> scheduledClasses;

  CalendarDaySchedule({
    required this.date,
    required this.isHoliday,
    required this.holidayNotices,
    required this.otherNotices,
    required this.scheduledClasses,
  });

  /// When a holiday falls on a day with scheduled classes,
  /// classes are cancelled and reminders are suppressed.
  bool get classesCancelledDueToHoliday => isHoliday && scheduledClasses.isNotEmpty;

  /// Returns only active classes if NOT a holiday. On a holiday, returns empty list.
  List<ClassSchedule> get activeClasses => isHoliday ? [] : scheduledClasses;

  /// Returns true if this day has any notices (holidays, exams, fee deadlines, events)
  bool get hasNotices => holidayNotices.isNotEmpty || otherNotices.isNotEmpty;

  /// Returns total event count (classes + notices)
  int get totalEventCount => (isHoliday ? 0 : scheduledClasses.length) + holidayNotices.length + otherNotices.length;

  /// Holiday names joined
  String get holidayNameSummary =>
      holidayNotices.map((n) => n.title).join(', ');
}
