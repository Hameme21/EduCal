import 'package:flutter/material.dart';
import '../state/calendar_state.dart';
import '../widgets/educal_logo.dart';
import 'dashboard/dashboard_screen.dart';
import 'notices/notices_screen.dart';
import 'setup/setup_screen.dart';
import 'reminders/notification_dialog.dart';
import 'reminders/reminder_settings_dialog.dart';

class MainScreen extends StatefulWidget {
  final CalendarState state;

  const MainScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _openReminderSettings() {
    showDialog(
      context: context,
      builder: (ctx) => ReminderSettingsDialog(
        currentSettings: widget.state.reminderSettings,
        onSave: (newSettings) {
          widget.state.updateReminderSettings(newSettings);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder preferences updated successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _openNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => NotificationDialog(
        notifications: widget.state.notifications,
        onMarkRead: (id) => widget.state.markNotificationRead(id),
        onMarkAllRead: () => widget.state.markAllNotificationsRead(),
        onOpenSettings: () {
          Navigator.of(ctx).pop();
          _openReminderSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = widget.state.unreadNotificationCount;

    return Scaffold(
      appBar: AppBar(
        title: EduCalLogo(
          size: 34,
          isDark: isDark,
        ),
        actions: [
          // 3-Way Theme Mode Selector (Light, Dark, System)
          PopupMenuButton<ThemeMode>(
            icon: Icon(
              widget.state.themeMode == ThemeMode.system
                  ? Icons.brightness_auto_rounded
                  : (widget.state.themeMode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded),
              size: 20,
            ),
            tooltip: 'Select Theme Mode',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (mode) => widget.state.setThemeMode(mode),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    const Icon(Icons.light_mode_rounded, size: 18, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 10),
                    const Text('Light Mode'),
                    if (widget.state.themeMode == ThemeMode.light) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded, size: 16, color: Color(0xFF3B82F6)),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode_rounded, size: 18, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 10),
                    const Text('Dark Mode'),
                    if (widget.state.themeMode == ThemeMode.dark) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded, size: 16, color: Color(0xFF3B82F6)),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    const Icon(Icons.brightness_auto_rounded, size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    const Text('System Default'),
                    if (widget.state.themeMode == ThemeMode.system) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded, size: 16, color: Color(0xFF3B82F6)),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Notification Bell
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: _openNotificationsDialog,
                tooltip: 'Reminders & Notifications',
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Academic Notices',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Class Setup',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(state: widget.state);
      case 1:
        return NoticesScreen(state: widget.state);
      case 2:
        return SetupScreen(state: widget.state);
      default:
        return DashboardScreen(state: widget.state);
    }
  }
}
