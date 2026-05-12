import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'data/sessions_provider.dart';
import 'data/settings_provider.dart';
import 'data/task_provider.dart';
import 'screens/root_screen.dart';
import 'services/daily_reminder_service.dart';
import 'services/focus_notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await FocusNotificationService.init();
  await DailyReminderService.init();

  // Charge les settings persistés avant de construire l'app, comme ça l'UI
  // démarre déjà avec la bonne valeur du toggle (pas de flash false → true).
  final settings = SettingsProvider();
  await settings.load();

  // À chaque changement de toggle/heure, on reprogramme la notif.
  settings.onReminderChanged = () {
    if (settings.dailyReminder) {
      DailyReminderService.schedule(settings.reminderTime);
    } else {
      DailyReminderService.cancel();
    }
  };

  // Pose la notif au boot si déjà activée par l'utilisateur.
  if (settings.dailyReminder) {
    // ignore: unawaited_futures
    DailyReminderService.schedule(settings.reminderTime);
  }

  // Status bar discrète, contenu sombre sur fond clair.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MomentumApp(settings: settings));
}

class MomentumApp extends StatelessWidget {
  const MomentumApp({super.key, required this.settings});

  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SessionsProvider()),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: MaterialApp(
        title: 'Momentum',
        debugShowCheckedModeBanner: false,
        theme: buildMomentumTheme(),
        home: const RootScreen(),
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
