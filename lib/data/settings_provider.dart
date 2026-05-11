import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  // Démarre désactivé : les rappels système ne sont pas encore branchés
  // (flutter_local_notifications viendra plus tard). On évite donc de
  // promettre au user un comportement qui n'existe pas.
  bool _dailyReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _language = 'Français';

  bool get dailyReminder => _dailyReminder;
  TimeOfDay get reminderTime => _reminderTime;
  String get language => _language;

  static const supportedLanguages = <String>[
    'Français',
    'English',
    'Español',
    'Deutsch',
    '日本語',
  ];

  void setDailyReminder(bool v) {
    _dailyReminder = v;
    notifyListeners();
  }

  void setReminderTime(TimeOfDay t) {
    _reminderTime = t;
    notifyListeners();
  }

  void setLanguage(String v) {
    _language = v;
    notifyListeners();
  }
}
