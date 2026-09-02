import 'package:flutter_test/flutter_test.dart';
import 'package:educal/services/file_parser_service.dart';
import 'package:educal/services/calendar_service.dart';
import 'package:educal/models/academic_notice.dart';
import 'package:educal/models/class_schedule.dart';

void main() {
  group('FileParserService Tests', () {
    test('Parse Class Schedule JSON', () {
      const jsonStr = '''[
        {
          "id": "CS101",
          "subject": "Algorithms",
          "courseCode": "CSE-201",
          "dayOfWeek": 1,
          "startTime": "09:00",
          "endTime": "10:30",
          "room": "Lab 402",
          "instructor": "Dr. Sarah",
          "color": "#4A90E2"
        }
      ]''';

      final result = FileParserService.parseClassSchedule(jsonStr);
      expect(result.isSuccess, isTrue);
      expect(result.items.length, equals(1));
      expect(result.items.first.subject, equals('Algorithms'));
      expect(result.items.first.dayOfWeek, equals(1));
    });

    test('Parse Class Schedule CSV', () {
      const csvStr = '''id,subject,courseCode,dayOfWeek,startTime,endTime,room,instructor,color
CS101,Algorithms,CSE-201,1,09:00,10:30,Lab 402,Dr. Sarah,#4A90E2
CS102,Databases,CSE-205,2,11:00,12:30,Room 301,Prof. Turing,#50E3C2''';

      final result = FileParserService.parseClassSchedule(csvStr);
      expect(result.isSuccess, isTrue);
      expect(result.items.length, equals(2));
      expect(result.items[0].subject, equals('Algorithms'));
      expect(result.items[1].subject, equals('Databases'));
      expect(result.items[1].dayOfWeek, equals(2));
    });

    test('Parse Class Schedule .ICS iCalendar', () {
      const icsStr = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//EduCal//Class Timetable//EN
BEGIN:VEVENT
UID:CLS-201
SUMMARY:CSE-201: Data Structures
DESCRIPTION:Instructor: Dr. Sarah Connor, Room: Lab 402
LOCATION:Lab 402
DTSTART:20260302T090000
DTEND:20260302T103000
RRULE:FREQ=WEEKLY;BYDAY=MO
END:VEVENT
END:VCALENDAR''';

      final result = FileParserService.parseClassSchedule(icsStr);
      expect(result.isSuccess, isTrue);
      expect(result.items.length, equals(1));
      expect(result.items.first.courseCode, equals('CSE-201'));
      expect(result.items.first.subject, equals('Data Structures'));
      expect(result.items.first.dayOfWeek, equals(1)); // Monday
      expect(result.items.first.startTime, equals('09:00'));
      expect(result.items.first.endTime, equals('10:30'));
    });

    test('Parse Academic Calendar .ICS iCalendar', () {
      const icsStr = '''BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
UID:HOL-101
SUMMARY:Independence Day
DESCRIPTION:National Holiday. Closed.
DTSTART;VALUE=DATE:20260326
DTEND;VALUE=DATE:20260326
CATEGORIES:HOLIDAY
END:VEVENT
END:VCALENDAR''';

      final result = FileParserService.parseAcademicCalendar(icsStr);
      expect(result.isSuccess, isTrue);
      expect(result.items.length, equals(1));
      expect(result.items.first.title, equals('Independence Day'));
      expect(result.items.first.isHoliday, isTrue);
    });

    test('Export .ICS excludes classes occurring on holidays', () {
      final calendarService = CalendarService();

      // Monday recurring class
      calendarService.addClass(ClassSchedule(
        id: 'CS101-MON',
        subject: 'Algorithms',
        courseCode: 'CSE-201',
        dayOfWeek: 1, // Monday
        startTime: '09:00',
        endTime: '10:30',
        room: 'Lab 402',
        instructor: 'Dr. Sarah',
      ));

      // 2026-08-24 is a Monday
      final monday = DateTime(2026, 8, 24);

      // Add a holiday on 2026-08-24
      calendarService.addNotice(AcademicNotice(
        id: 'HOL-001',
        title: 'National Mourning Holiday',
        description: 'University closed',
        startDate: monday,
        endDate: monday,
        category: NoticeCategory.holiday,
        isHoliday: true,
      ));

      // Export for that specific week
      final icsOutput = FileParserService.exportCalendarToIcs(
        calendarService,
        startDate: monday,
        endDate: monday,
      );

      // ICS must include the holiday
      expect(icsOutput, contains('National Mourning Holiday'));

      // Crucial logic: ICS must NOT have class events for 20260824 because it is a holiday
      expect(icsOutput, isNot(contains('UID:CLS-CS101-MON-20260824@educal.app')));
    });
  });
}
