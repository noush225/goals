// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Goals';

  @override
  String get homeTitle => 'Home';

  @override
  String dbConnectionStatus(String status) {
    return 'Database Status: $status';
  }

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get today => 'Today';

  @override
  String get week => 'This week';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get title => 'Title';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get oneShot => 'One-shot';

  @override
  String get progression => 'Progression';

  @override
  String get parentTask => 'Parent Task';

  @override
  String get none => 'None';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get emptyTasks => 'No tasks yet. Begin your journey.';

  @override
  String get requiredField => 'This field is required';

  @override
  String progress(String value) {
    return 'Progress: $value%';
  }

  @override
  String timeSpent(String time) {
    return 'Time spent: $time';
  }
}
