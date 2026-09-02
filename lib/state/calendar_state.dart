import 'package:flutter/material.dart';
import '../models/class_schedule.dart';
import '../models/academic_notice.dart';
import '../models/calendar_day_schedule.dart';
import '../models/reminder_notification.dart';
import '../services/calendar_service.dart';
import '../services/reminder_service.dart';
import '../services/sample_data_service.dart';
import '../services/file_parser_service.dart';

import '../models/reminder_settings.dart';

class CalendarState extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();
  late final ReminderService _reminderService;

  DateTime _selectedDate = DateTime.now();
  ThemeMode _themeMode = ThemeMode.system;

  NoticeCategory? _selectedNoticeFilter;
  String _noticeSearchQuery = '';

  CalendarState() {
    _reminderService = ReminderService(_calendarService);
    // Initialize with rich sample data by default so the user immediately gets a live experience
    loadSampleData(notify: false);
  }

  // Getters
  CalendarService get calendarService => _calendarService;
  ReminderService get reminderService => _reminderService;
  ReminderSettings get reminderSettings => _reminderService.settings;
  DateTime get selectedDate => _selectedDate;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  NoticeCategory? get selectedNoticeFilter => _selectedNoticeFilter;
  String get noticeSearchQuery => _noticeSearchQuery;

  List<ClassSchedule> get classes => _calendarService.classes;
  List<AcademicNotice> get notices => _calendarService.notices;
  List<ReminderNotification> get notifications => _reminderService.notifications;
  int get unreadNotificationCount => _reminderService.unreadCount;

  CalendarDaySchedule get selectedDaySchedule => _calendarService.getDaySchedule(_selectedDate);

  List<AcademicNotice> get upcomingNotices => _calendarService.getUpcomingNotices(
        category: _selectedNoticeFilter,
        query: _noticeSearchQuery,
      );

  Map<String, int> get dashboardStats => _calendarService.getDashboardStats(_selectedDate);

  // Actions
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    cycleThemeMode();
  }

  void cycleThemeMode() {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void setNoticeFilter(NoticeCategory? category) {
    _selectedNoticeFilter = category;
    notifyListeners();
  }

  void setNoticeSearchQuery(String query) {
    _noticeSearchQuery = query;
    notifyListeners();
  }

  void loadSampleData({bool notify = true}) {
    _calendarService.setClasses(SampleDataService.getSampleClasses());
    _calendarService.setNotices(SampleDataService.getSampleNotices());
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    if (notify) notifyListeners();
  }

  void clearAllData() {
    _calendarService.setClasses([]);
    _calendarService.setNotices([]);
    _reminderService.clearAll();
    notifyListeners();
  }

  ParseResult<ClassSchedule> importClassSchedule(String content) {
    final result = FileParserService.parseClassSchedule(content);
    if (result.isSuccess) {
      _calendarService.setClasses(result.items);
      _reminderService.refreshReminders(referenceDate: _selectedDate);
      notifyListeners();
    }
    return result;
  }

  ParseResult<AcademicNotice> importAcademicCalendar(String content) {
    final result = FileParserService.parseAcademicCalendar(content);
    if (result.isSuccess) {
      _calendarService.setNotices(result.items);
      _reminderService.refreshReminders(referenceDate: _selectedDate);
      notifyListeners();
    }
    return result;
  }

  void addClass(ClassSchedule classSchedule) {
    _calendarService.addClass(classSchedule);
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    notifyListeners();
  }

  void updateClass(ClassSchedule classSchedule) {
    _calendarService.updateClass(classSchedule);
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    notifyListeners();
  }

  void deleteClass(String id) {
    _calendarService.removeClass(id);
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    notifyListeners();
  }

  void addNotice(AcademicNotice notice) {
    _calendarService.addNotice(notice);
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    notifyListeners();
  }

  void updateNotice(AcademicNotice notice) {
    _calendarService.updateNotice(notice);
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    notifyListeners();
  }

  void deleteNotice(String id) {
    _calendarService.removeNotice(id);
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    notifyListeners();
  }

  void customizeClassReminder({
    required ClassSchedule classSchedule,
    required int minutesBefore,
    required bool applyToAll,
    required bool enabled,
  }) {
    if (applyToAll) {
      _reminderService.updateSettings(
        _reminderService.settings.copyWith(
          classReminderMinutesBefore: minutesBefore,
          enableClassReminders: enabled,
        ),
        referenceDate: _selectedDate,
      );
      // Clear custom overrides across all classes so they use the global setting
      for (var c in _calendarService.classes) {
        if (c.customReminderMinutes != null || c.reminderEnabled != enabled) {
          _calendarService.updateClass(c.copyWith(clearCustomReminder: true, reminderEnabled: enabled));
        }
      }
    } else {
      _calendarService.updateClass(
        classSchedule.copyWith(
          customReminderMinutes: minutesBefore,
          reminderEnabled: enabled,
        ),
      );
    }
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    notifyListeners();
  }

  void customizeNoticeReminder({
    required AcademicNotice notice,
    required TimeOfDay reminderTime,
    required bool dayBefore,
    required bool applyToAll,
    required bool enabled,
  }) {
    if (applyToAll) {
      if (notice.isHoliday) {
        _reminderService.updateSettings(
          _reminderService.settings.copyWith(
            holidayReminderTime: reminderTime,
            enableHolidayReminders: enabled,
          ),
          referenceDate: _selectedDate,
        );
        for (var n in _calendarService.notices.where((n) => n.isHoliday)) {
          _calendarService.updateNotice(n.copyWith(clearCustomReminder: true, reminderEnabled: enabled));
        }
      } else {
        _reminderService.updateSettings(
          _reminderService.settings.copyWith(
            normalEventReminderTime: reminderTime,
            normalEventRemindDayBefore: dayBefore,
            enableNormalEventReminders: enabled,
          ),
          referenceDate: _selectedDate,
        );
        for (var n in _calendarService.notices.where((n) => !n.isHoliday)) {
          _calendarService.updateNotice(n.copyWith(clearCustomReminder: true, reminderEnabled: enabled));
        }
      }
    } else {
      _calendarService.updateNotice(
        notice.copyWith(
          customReminderTime: reminderTime,
          customRemindDayBefore: dayBefore,
          reminderEnabled: enabled,
        ),
      );
    }
    _reminderService.refreshReminders(referenceDate: _selectedDate);
    notifyListeners();
  }

  void updateReminderSettings(ReminderSettings settings) {
    _reminderService.updateSettings(settings, referenceDate: _selectedDate);
    notifyListeners();
  }

  void markNotificationRead(String id) {
    _reminderService.markAsRead(id);
    notifyListeners();
  }

  void markAllNotificationsRead() {
    _reminderService.markAllAsRead();
    notifyListeners();
  }
}
