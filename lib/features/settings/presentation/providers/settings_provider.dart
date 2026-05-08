import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goals/core/notifications/notification_service.dart';
import 'package:goals/features/tasks/data/task_repository.dart';
import 'package:goals/l10n/generated/app_localizations.dart';

class SettingsProvider with ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  final NotificationService _notificationService = NotificationService();
  
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  bool get isReminderEnabled => _isReminderEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isReminderEnabled = prefs.getBool('reminder_enabled') ?? false;
    final hour = prefs.getInt('reminder_hour') ?? 9;
    final minute = prefs.getInt('reminder_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: hour, minute: minute);
    notifyListeners();
  }

  Future<void> toggleReminder(bool value, AppLocalizations l10n) async {
    _isReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', value);
    
    if (_isReminderEnabled) {
      final granted = await _notificationService.requestPermissions();
      if (granted) {
        await updateReminder(l10n);
      } else {
        _isReminderEnabled = false;
        await prefs.setBool('reminder_enabled', false);
      }
    } else {
      await _notificationService.cancelAll();
    }
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time, AppLocalizations l10n) async {
    _reminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    
    if (_isReminderEnabled) {
      await updateReminder(l10n);
    }
    notifyListeners();
  }

  /// Checks if there are pending tasks for today and schedules/cancels reminder accordingly.
  Future<void> updateReminder(AppLocalizations l10n) async {
    if (!_isReminderEnabled) return;

    final tasks = await _taskRepository.getAllTasks();
    final now = DateTime.now();
    
    // Check if there are tasks for "today" (relative to when the reminder would fire)
    // Actually, we check if there are tasks for the day of the next scheduled reminder.
    
    final hasTasksForToday = tasks.any((task) => 
        task.date.year == now.year && 
        task.date.month == now.month && 
        task.date.day == now.day);

    if (hasTasksForToday) {
      debugPrint('[SettingsProvider] Pending tasks found, scheduling reminder');
      await _notificationService.scheduleDailyReminder(
        id: 100,
        title: l10n.reminderTitle,
        body: l10n.reminderBody,
        time: _reminderTime,
      );
    } else {
      debugPrint('[SettingsProvider] No pending tasks found for today, cancelling reminder');
      await _notificationService.cancelNotification(100);
      
      // If no tasks today, we might want to check for tomorrow if it's already past today's reminder time.
      // For simplicity, we'll re-run this check whenever tasks change.
    }
  }

  Future<void> sendTestNotification(AppLocalizations l10n) async {
    final granted = await _notificationService.requestPermissions();
    if (granted) {
      await _notificationService.showNotification(
        id: 999,
        title: 'Test Notification',
        body: 'This is a test to verify notifications are working.',
      );
    }
  }
}
