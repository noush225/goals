import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter/material.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[NotificationService] Notification clicked: ${details.payload}');
      },
    );

    debugPrint('[NotificationService] Initialized');
  }

  Future<void> showFocusTimerNotification(String taskTitle) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'focus_channel_id',
        'Focus Mode Timer',
        channelDescription: 'Displays the ongoing focus session timer',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
        usesChronometer: true,
        when: 0,
      );

      await _notificationsPlugin.show(
        888,
        'Working on:',
        taskTitle,
        const NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      debugPrint('[NotificationService] Launched native chronometer for: $taskTitle');
    } catch (e) {
      debugPrint('[NotificationService] Error launching chronometer: $e');
    }
  }

  Future<void> cancelFocusTimerNotification() async {
    await _notificationsPlugin.cancel(888);
    debugPrint('[NotificationService] Focus notification canceled.');
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      debugPrint('[NotificationService] iOS Permissions: $result');
      return result ?? false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotification = await androidImplementation?.requestNotificationsPermission();
      
      debugPrint('[NotificationService] Android Permissions: $grantedNotification');
      return grantedNotification ?? false;
    }
    return false;
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('[NotificationService] Scheduling daily reminder at: $scheduledDate');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Notifications to remind you of your daily goals',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    debugPrint('[NotificationService] Showing immediate notification: $id');
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Used to test notification system',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    debugPrint('[NotificationService] Cancelling notification: $id');
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    debugPrint('[NotificationService] Cancelling all notifications');
    await _notificationsPlugin.cancelAll();
  }
}
