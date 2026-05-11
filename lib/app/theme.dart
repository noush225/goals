import 'package:flutter/material.dart';

/// Palette « Sage » — Empathetic Minimalist.
/// Couleurs reprises 1:1 de design/DESIGN.md + app.jsx.
class AppColors {
  AppColors._();

  // Surfaces
  static const bg = Color(0xFFF4F1EA);
  static const surface = Color(0xFFFBF9F4);
  static const surfaceSunk = Color(0xFFEDE9DF);

  // Encre & texte
  static const ink = Color(0xFF2D3A2E);
  static const inkSoft = Color(0xFF5A6660);
  static const muted = Color(0xFF9A968C);

  // Accent (Sage Green)
  static const accent = Color(0xFF6B8268);
  static const accentLight = Color(0xFFA8BFA1);
  static const accentShadow = Color(0x666B8268);
  static const inkShadow = Color(0x592D3A2E);
  static const hairline = Color(0x142D3A2E);

  // Focus mode (sombre, immersif)
  static const focusBg = Color(0xFF14181A);
  static const focusInk = Color(0xFFEAE6DA);
  static const focusInkSoft = Color(0xB3EAE6DA);
  static const focusMuted = Color(0x73EAE6DA);
  static const focusAccent = Color(0xFFA8BFA1);
  static const focusTimer = Color(0xFFF2EFE6);
  static const focusRing = Color(0x14EAE6DA);
  static const focusRingFaint = Color(0x0AEAE6DA);
  static Color focusTimerGlow = focusAccent.withOpacity(0.33);
  static Color focusGlow = focusAccent.withOpacity(0.13);
}

/// Rayons standards (organique, non-industriel).
class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 22.0;
  static const card = 22.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

/// Échelle de spacing 8px.
class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const screenPad = 24.0;
}

/// Typographie : police système (Roboto / SF Pro).
///
/// Si tu veux la vraie Manrope plus tard :
/// 1. Télécharge Manrope-{Regular,Medium,SemiBold,Bold}.ttf depuis fonts.google.com
/// 2. Place-les dans `assets/fonts/`
/// 3. Déclare-les dans pubspec.yaml > flutter > fonts:
/// 4. Décommente `fontFamily: 'Manrope'` ci-dessous et dans buildMomentumTheme
class AppText {
  AppText._();

  static TextTheme buildTextTheme() {
    return const TextTheme(
      // Grand titre éditorial (réservé aux futurs écrans type onboarding)
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: -0.8,
        color: AppColors.ink,
      ),
      // Headline = "Que cette journée compte"
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.84,
        color: AppColors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.55,
        color: AppColors.ink,
      ),
      // Title de carte
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.38,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.16,
        color: AppColors.ink,
      ),
      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.inkSoft,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      ),
      // Labels (chips, kicker uppercase)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.14,
        color: AppColors.ink,
      ),
      labelMedium: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.7,
        color: AppColors.muted,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.muted,
      ),
    );
  }
}

ThemeData buildMomentumTheme() {
  final textTheme = AppText.buildTextTheme();
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    canvasColor: AppColors.bg,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    // fontFamily: 'Manrope', // décommente quand tu bundles la police
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.surface,
      secondary: AppColors.accentLight,
      onSecondary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: Color(0xFFB8755C),
      onError: Colors.white,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.surface,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
    ),
    iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
  );
}
