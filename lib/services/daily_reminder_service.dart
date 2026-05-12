import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Service de rappel quotidien.
///
/// Programme une notif daily à l'heure choisie par l'utilisateur dans Settings.
/// Reprogramme à chaque changement de toggle ou d'heure.
class DailyReminderService {
  DailyReminderService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'momentum_daily_reminder';
  static const String _channelName = 'Rappel quotidien';
  static const String _channelDesc =
      'Petit rappel doux pour démarrer ta journée créative';
  static const int _notifId = 1010;

  static bool _initialized = false;

  /// Init des timezones + channel Android. Idempotent.
  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // Si on n'arrive pas à détecter la TZ, on reste sur UTC ; le scheduling
      // peut être décalé mais ça ne crashe pas.
    }

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.defaultImportance,
    );
    await androidImpl?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// (Re)programme la notif daily à l'heure donnée.
  /// Annule l'éventuelle précédente avant de poser la nouvelle.
  static Future<void> schedule(TimeOfDay time) async {
    if (!_initialized) await init();
    await cancel();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    // Si l'heure est déjà passée aujourd'hui, on cible demain.
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      category: AndroidNotificationCategory.reminder,
    );
    const iosDetails = DarwinNotificationDetails();

    try {
      await _plugin.zonedSchedule(
        _notifId,
        'Momentum',
        "C'est l'heure de faire avancer tes idées ✨",
        scheduled,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Si on n'a pas la perm exact-alarm ou autre, on log mais on crashe pas.
      if (kDebugMode) {
        debugPrint('[DailyReminder] schedule failed: $e');
      }
    }
  }

  /// Annule la notif scheduled.
  static Future<void> cancel() => _plugin.cancel(_notifId);
}
