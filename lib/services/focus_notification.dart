import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/time_format.dart';

/// Actions émises par la notification ongoing du Focus Mode.
enum FocusNotifAction { pauseOrResume, stop }

/// Service singleton pour gérer la notification persistante du Focus Mode.
///
/// • [init] doit être appelé au boot (main.dart).
/// • [show] crée ou met à jour la notif. À appeler à chaque tick du timer.
/// • [dismiss] retire la notif (en fin/annulation de session).
/// • [actions] : stream broadcast pour réagir aux taps Pause / Reprendre / Terminer.
class FocusNotificationService {
  FocusNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'momentum_focus_session';
  static const String _channelName = 'Session de concentration';
  static const String _channelDesc =
      'Affiche le temps écoulé pendant une session de focus';
  static const int _notifId = 4242;

  static final StreamController<FocusNotifAction> _actionsCtrl =
      StreamController<FocusNotifAction>.broadcast();

  /// À écouter depuis FocusScreen.
  static Stream<FocusNotifAction> get actions => _actionsCtrl.stream;

  static bool _initialized = false;

  /// Initialise le plugin + crée le channel Android.
  static Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Channel "low" : pas de son ni vibration sur chaque update.
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await androidImpl?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Demande la permission POST_NOTIFICATIONS (Android 13+) si pas déjà accordée.
  /// Retourne true si l'utilisateur a accepté (ou si la perm n'est pas requise).
  static Future<bool> requestPermission() async {
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImpl?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Crée ou met à jour la notif ongoing.
  static Future<void> show({
    required String taskTitle,
    required int elapsedSec,
    required bool paused,
  }) async {
    if (!_initialized) await init();

    final body = paused
        ? 'En pause · ${formatMMSS(elapsedSec)}'
        : '${formatMMSS(elapsedSec)} écoulées';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: !paused, // empêche le swipe-away tant que la session tourne
      autoCancel: false,
      showWhen: false,
      onlyAlertOnce: true, // pas de son/vibration sur chaque update
      category: AndroidNotificationCategory.stopwatch,
      visibility: NotificationVisibility.public, // visible sur lock screen
      silent: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'pause',
          paused ? 'Reprendre' : 'Pause',
          showsUserInterface: false,
          cancelNotification: false,
        ),
        const AndroidNotificationAction(
          'stop',
          'Terminer',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
      interruptionLevel: InterruptionLevel.passive,
    );

    await _plugin.show(
      _notifId,
      taskTitle,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  /// Retire la notification.
  static Future<void> dismiss() => _plugin.cancel(_notifId);

  static void _onResponse(NotificationResponse resp) {
    final action = _parseAction(resp.actionId);
    if (action != null) _actionsCtrl.add(action);
  }

  /// Handler background — doit être top-level ou static + pragma vm:entry-point.
  /// Voir doc flutter_local_notifications.
  @pragma('vm:entry-point')
  static void _onBackgroundResponse(NotificationResponse resp) {
    final action = _parseAction(resp.actionId);
    if (action != null) _actionsCtrl.add(action);
  }

  static FocusNotifAction? _parseAction(String? id) {
    switch (id) {
      case 'pause':
        return FocusNotifAction.pauseOrResume;
      case 'stop':
        return FocusNotifAction.stop;
      default:
        return null;
    }
  }
}
