import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/presentation/providers/task_provider.dart';
import 'features/tasks/presentation/screens/task_list_screen.dart';
import 'features/focus/services/audio_handler.dart';
import 'l10n/generated/app_localizations.dart';

// Global instance to be used across the app
late GoalsAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  audioHandler = await AudioService.init(
    builder: () => GoalsAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.goals.channel.audio',
      androidNotificationChannelName: 'Focus Mode Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const GoalsApp(),
    ),
  );
}

class GoalsApp extends StatelessWidget {
  const GoalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''),
        Locale('en', ''),
      ],
      locale: const Locale('fr', ''), // Default locale
      theme: AppTheme.lightTheme,
      home: const TaskListScreen(),
    );
  }
}
