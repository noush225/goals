import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kDailyReminder = 'settings.dailyReminder';
  static const _kReminderHour = 'settings.reminderHour';
  static const _kReminderMinute = 'settings.reminderMinute';
  static const _kLanguage = 'settings.language';
  static const _kUserName = 'settings.userName';

  bool _dailyReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _language = 'Français';
  String _userName = '';
  bool _loaded = false;

  /// Callback déclenché à chaque changement qui affecte le scheduling
  /// (toggle ou heure). Le wiring depuis main.dart écoute pour
  /// (re)programmer la notif via DailyReminderService.
  VoidCallback? onReminderChanged;

  bool get dailyReminder => _dailyReminder;
  TimeOfDay get reminderTime => _reminderTime;
  String get language => _language;
  String get userName => _userName;
  bool get hasUserName => _userName.trim().isNotEmpty;
  bool get loaded => _loaded;

  static const supportedLanguages = <String>[
    'Français',
    'English',
    'Español',
    'Deutsch',
    '日本語',
  ];

  /// Charge depuis disque. À appeler une seule fois au boot.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyReminder = prefs.getBool(_kDailyReminder) ?? false;
    final h = prefs.getInt(_kReminderHour) ?? 9;
    final m = prefs.getInt(_kReminderMinute) ?? 0;
    _reminderTime = TimeOfDay(hour: h, minute: m);
    _language = prefs.getString(_kLanguage) ?? 'Français';
    _userName = prefs.getString(_kUserName) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDailyReminder, _dailyReminder);
    await prefs.setInt(_kReminderHour, _reminderTime.hour);
    await prefs.setInt(_kReminderMinute, _reminderTime.minute);
    await prefs.setString(_kLanguage, _language);
    await prefs.setString(_kUserName, _userName);
  }

  void setDailyReminder(bool v) {
    _dailyReminder = v;
    notifyListeners();
    _save();
    onReminderChanged?.call();
  }

  void setReminderTime(TimeOfDay t) {
    _reminderTime = t;
    notifyListeners();
    _save();
    onReminderChanged?.call();
  }

  void setLanguage(String v) {
    _language = v;
    notifyListeners();
    _save();
  }

  void setUserName(String v) {
    _userName = v.trim();
    notifyListeners();
    _save();
  }
}
