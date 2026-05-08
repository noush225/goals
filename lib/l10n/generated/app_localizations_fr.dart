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

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get week => 'Cette semaine';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get title => 'Titre';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get oneShot => 'Ponctuelle';

  @override
  String get progression => 'Progression';

  @override
  String get parentTask => 'Tâche parente';

  @override
  String get none => 'Aucune';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get emptyTasks =>
      'Aucune tâche pour le moment. Commencez votre voyage.';

  @override
  String get requiredField => 'Ce champ est requis';

  @override
  String progress(String value) {
    return 'Progression : $value%';
  }

  @override
  String timeSpent(String time) {
    return 'Temps passé : $time';
  }
}
