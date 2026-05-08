// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Objectifs';

  @override
  String get homeTitle => 'Accueil';

  @override
  String dbConnectionStatus(String status) {
    return 'Statut de la base de données : $status';
  }

  @override
  String get connected => 'Connecté';

  @override
  String get disconnected => 'Déconnecté';
}
