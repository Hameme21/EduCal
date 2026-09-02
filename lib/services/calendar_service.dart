import '../models/class_schedule.dart';
import '../models/academic_notice.dart';
import '../models/calendar_day_schedule.dart';

class CalendarService {
  final List<ClassSchedule> _classes = [];
  final List<AcademicNotice> _notices = [];

  List<ClassSchedule> get classes => List.unmodifiable(_classes);
  List<AcademicNotice> get notices => List.unmodifiable(_notices);

  void setClasses(List<ClassSchedule> newClasses) {
    _classes.clear();
    _classes.addAll(newClasses);
  }

  void addClass(ClassSchedule classSchedule) {
    _classes.add(classSchedule);
  }

  void removeClass(String id) {
    _classes.removeWhere((c) => c.id == id);
  }

  void updateClass(ClassSchedule updated) {
    final index = _classes.indexWhere((c) => c.id == updated.id);
    if (index >= 0) {
      _classes[index] = updated;
    }
  }

  void setNotices(List<AcademicNotice> newNotices) {
    _notices.clear();
    _notices.addAll(newNotices);
  }

  void addNotice(AcademicNotice notice) {
    _notices.add(notice);
  }

  void removeNotice(String id) {
    _notices.removeWhere((n) => n.id == id);
  }

  void updateNotice(AcademicNotice updated) {
    final index = _notices.indexWhere((n) => n.id == updated.id);
    if (index >= 0) {
      _notices[index] = updated;
    }
  }

  /// Checks whether a given date is marked as a holiday in the academic calendar
  bool isHoliday(DateTime date) {
    return _notices.any((n) => n.isHoliday && n.coversDate(date));
  }

  /// Returns holiday notices that cover the given date
  List<AcademicNotice> getHolidayNotices(DateTime date) {
    return _notices.where((n) => n.isHoliday && n.coversDate(date)).toList();
  }

  /// Returns non-holiday academic notices active on that date (fees, exams, events)
  List<AcademicNotice> getOtherNotices(DateTime date) {
    return _notices.where((n) => !n.isHoliday && n.coversDate(date)).toList();
  }

  /// Returns scheduled classes for the day-of-week (1 = Mon ... 7 = Sun)
  List<ClassSchedule> getScheduledClassesForDayOfWeek(int dayOfWeek) {
    final list = _classes.where((c) => c.dayOfWeek == dayOfWeek).toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  /// Computes day schedule and enforces the Holiday Conflict Resolution Rule:
  /// "holidays do not have class if a holiday and class at the same date then no classes will be notified"
  CalendarDaySchedule getDaySchedule(DateTime date) {
    final hol = isHoliday(date);
    final holNotices = getHolidayNotices(date);
    final otherNotices = getOtherNotices(date);
    final scheduledClasses = getScheduledClassesForDayOfWeek(date.weekday);

    return CalendarDaySchedule(
      date: DateTime(date.year, date.month, date.day),
      isHoliday: hol,
      holidayNotices: holNotices,
      otherNotices: otherNotices,
      scheduledClasses: scheduledClasses,
    );
  }

  /// Returns filtered and sorted upcoming notices from a given date
  List<AcademicNotice> getUpcomingNotices({
    DateTime? fromDate,
    NoticeCategory? category,
    String? query,
    bool includePast = false,
  }) {
    final baseDate = fromDate ?? DateTime.now();
    final today = DateTime(baseDate.year, baseDate.month, baseDate.day);

    var filtered = _notices.where((n) {
      if (!includePast) {
        final end = DateTime(n.endDate.year, n.endDate.month, n.endDate.day);
        if (end.isBefore(today)) return false;
      }

      if (category != null && n.category != category) {
        return false;
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        final matchTitle = n.title.toLowerCase().contains(q);
        final matchDesc = n.description.toLowerCase().contains(q);
        final matchCat = n.categoryName.toLowerCase().contains(q);
        if (!matchTitle && !matchDesc && !matchCat) return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
    return filtered;
  }

  /// Summary statistics for the dashboard
  Map<String, int> getDashboardStats([DateTime? forDate]) {
    final date = forDate ?? DateTime.now();
    final daySched = getDaySchedule(date);

    final upcomingHolidays = _notices.where((n) {
      if (!n.isHoliday) return false;
      return !n.endDate.isBefore(DateTime(date.year, date.month, date.day));
    }).length;

    final pendingFees = _notices.where((n) {
      if (n.category != NoticeCategory.semesterFee) return false;
      return !n.endDate.isBefore(DateTime(date.year, date.month, date.day));
    }).length;

    return {
      'classesToday': daySched.activeClasses.length,
      'isHolidayToday': daySched.isHoliday ? 1 : 0,
      'cancelledClassesToday': daySched.classesCancelledDueToHoliday ? daySched.scheduledClasses.length : 0,
      'upcomingHolidays': upcomingHolidays,
      'pendingFees': pendingFees,
      'totalClassesLoaded': _classes.length,
      'totalNoticesLoaded': _notices.length,
    };
  }
}
