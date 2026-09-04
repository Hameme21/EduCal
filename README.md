# EduCal - Academic Calendar & Smart Reminder App

**EduCal** is a Flutter/Dart application crafted for students, educators, and academic institutions to manage recurring class timetables, official academic calendars (holidays, fee deadlines, exams), and notification reminders.

---

## 🌟 Key Features

1. **Tab 1: Dashboard Calendar**
   - Interactive calendar with month & date navigation and event indicator dots.
   - Selected date agenda with daily timetable breakdown, instructor details, rooms, and active notices.
   - **Holiday Conflict Resolver**: Automatically detects if a date is marked as an academic holiday. When a holiday falls on a class day:
     - Prominent holiday banner is displayed.
     - Scheduled classes for that day are marked **Cancelled / No Class**.
     - All reminder notifications for those classes are automatically **silenced / suppressed**.

2. **Tab 2: Upcoming Notices**
   - Comprehensive feed of upcoming academic milestones:
     - 🎉 **Holidays & Recesses**
     - 💳 **Semester Fee Payment Deadlines** (with relative urgency countdowns, e.g. "Due in 3 days")
     - 📝 **Examination Schedules**
     - 📋 **Administrative & Elective Deadlines**
     - 🎪 **University Events & Hackathons**
   - Filter chips, real-time search, reminder toggle per notice, and custom notice builder dialog.

3. **Tab 3: Calendar Setup**
   - Ingest **Class Routine File** (supports JSON and CSV).
   - Ingest **Academic Calendar File** (supports JSON and CSV).
   - Instant 1-tap **Demo Preset Loader** (loads Computer Science Semester 2026 timetable and academic schedule).
   - Built-in CSV & JSON format guides with copyable templates.
   - Manual Class and Routine manager with custom card accent colors.

4. **Reminder & Notification Engine**
   - Notification bell in the App Bar showing active reminders.
   - Triggers reminders 10 minutes before classes, prior to fee deadlines, before exams, and on holidays.
   - Displays silenced/muted notifications with the reason (*"Silenced by Holiday Rule"*).
   - Full dark mode and light mode support.

---

## 📁 Project Structure

```
educal/
├── lib/
│   ├── main.dart                               # App entrypoint
│   ├── models/
│   │   ├── class_schedule.dart                 # Recurring weekly class model
│   │   ├── academic_notice.dart                # Academic notice & holiday model
│   │   ├── calendar_day_schedule.dart          # Aggregated daily schedule model
│   │   └── reminder_notification.dart          # Notification & reminder model
│   ├── services/
│   │   ├── calendar_service.dart               # Core holiday & schedule merge service
│   │   ├── file_parser_service.dart            # JSON and CSV routine & calendar parser
│   │   ├── reminder_service.dart               # Reminder scheduler & holiday suppressor
│   │   └── sample_data_service.dart            # Preloaded university sample datasets
│   ├── state/
│   │   └── calendar_state.dart                 # Central state manager (ChangeNotifier)
│   ├── theme/
│   │   └── app_theme.dart                      # Modern Material 3 themes (Light & Dark)
│   └── screens/
│       ├── main_screen.dart                    # BottomNavigationBar with 3 tabs
│       ├── dashboard/                          # Tab 1: Dashboard calendar & daily schedule
│       ├── notices/                            # Tab 2: Upcoming notices & add notice
│       ├── setup/                              # Tab 3: File ingestion & class builder
│       └── reminders/                          # Notification bell modal dialog
├── sample_data/
│   ├── class_schedule_sample.json              # Sample class routine (JSON)
│   ├── class_schedule_sample.csv               # Sample class routine (CSV)
│   ├── academic_calendar_sample.json           # Sample academic calendar (JSON)
│   └── academic_calendar_sample.csv            # Sample academic calendar (CSV)
└── test/
    ├── calendar_service_test.dart              # Holiday suppression logic unit tests
    ├── file_parser_service_test.dart           # CSV/JSON/ICS parser unit tests
    └── widget_test.dart                        # Flutter widget test
```

---

## 🚀 How to Run the App

1. Ensure Flutter is installed and configured in your environment.
2. Open terminal in this directory:
   ```bash
   cd C:\Users\hamim\.gemini\antigravity\scratch\educal
   ```
3. Get packages:
   ```bash
   flutter pub get
   ```
4. Run unit tests:
   ```bash
   flutter test
   ```
5. Launch the application:
   ```bash
   flutter run
   ```
