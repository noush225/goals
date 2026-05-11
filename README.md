# Momentum

App mobile minimaliste de productivité et de tracking du temps pour créatifs.
MVP en **Flutter** (iOS + Android), 4 écrans : Dashboard, Add Task, Focus Mode, Réglages.

Le design suit la philosophie « Empathetic Minimalist » (palette Sage, typographies
Manrope + Noto Serif). La référence visuelle complète vit dans `design/DESIGN.md`
et la maquette React dans `screens.jsx` / `app.jsx`.

## Stack

- Flutter 3.22+ / Dart 3.4+
- `provider` pour l'état (in-memory, aucune persistance pour le MVP)
- `google_fonts` (Manrope + Noto Serif chargées dynamiquement)
- `intl` (formatage de date en français)
- `audioplayers` (musique d'ambiance en boucle pendant le Focus Mode)

## Structure

```
lib/
├── main.dart                  # Entrée, MultiProvider, MaterialApp (locale fr_FR)
├── app/
│   └── theme.dart             # Palette Sage + AppColors / AppSpacing / AppText
├── data/
│   ├── task.dart              # Modèle Task + enum TaskType
│   ├── task_provider.dart     # ChangeNotifier in-memory + SEED FR
│   └── settings_provider.dart # Rappel quotidien, heure, langue
├── screens/
│   ├── home_screen.dart       # Dashboard "Aujourd'hui / Cette semaine" + FAB
│   ├── add_task_sheet.dart    # Bottom sheet de création de tâche
│   ├── focus_screen.dart      # Plein écran sombre, timer MM:SS, musique
│   └── settings_screen.dart   # Notifications + langue
├── widgets/
│   ├── press_button.dart      # Bouton qui « scale » au press (haptique-like)
│   ├── momentum_logo.dart     # Wordmark + petit carré sage
│   ├── segmented_tabs.dart    # Segmented control iOS-style
│   └── task_card.dart         # Carte de tâche du dashboard
└── utils/
    └── time_format.dart       # formatMinutes(95) → "1h 35m", formatMMSS(125) → "02:05"
```

## Premier lancement

> Ce repo contient `pubspec.yaml` + `lib/` + `assets/audio/` mais **pas encore les
> dossiers de plateformes** (`ios/`, `android/`, etc.). Il faut donc les scaffolder.

```bash
# 1. Générer les dossiers ios/ android/ etc. SANS écraser pubspec.yaml ni lib/
flutter create . --project-name momentum --org com.kadjo.momentum \
                 --platforms=ios,android,macos --no-overwrite

# 2. Installer les deps
flutter pub get

# 3. Lancer sur un simulateur iOS ou un appareil
flutter run
```

Si `flutter create` se plaint que le projet existe, ajoute `--no-pub` et relance
`flutter pub get` derrière. Le `--no-overwrite` est important pour préserver les
fichiers déjà écrits dans `lib/` et le `pubspec.yaml` custom.

## Points à connaître

- **Pas de persistance** : les tâches sont mockées via `SEED_TASKS` dans `TaskProvider`. Au prochain MVP, brancher SharedPreferences ou Hive.
- **Audio** : le Focus Mode joue `assets/audio/drawingsample1.mp3` en boucle. C'est un placeholder pour « Pluie en forêt » — remplace par un vrai field-recording quand prêt.
- **Langue** : interface entièrement en FR. Le sélecteur dans Réglages change la valeur dans `SettingsProvider` mais ne bascule pas encore les textes (à brancher avec `flutter_localizations` + fichiers `.arb` dans une prochaine itération).
- **Date picker** : volontairement minimaliste, calendrier inline (mois courant + flèches). Pas d'heure (anti-stress).

## Crédits design

`design/DESIGN.md` — système « Empathetic Minimalist ».
`screens.jsx` / `app.jsx` — maquette React/JS interactive (`Momentum.html`).
