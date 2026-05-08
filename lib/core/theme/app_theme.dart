import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color sageGreen = Color(0xFF516051);
  static const Color parchment = Color(0xFFFCF9F8);
  static const Color deepCharcoal = Color(0xFF1B1C1C);
  static const Color terracotta = Color(0xFF8B4E36);
  static const Color surfaceLow = Color(0xFFF6F3F2);
  static const Color outline = Color(0xFF747872);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: sageGreen,
        onPrimary: Colors.white,
        secondary: terracotta,
        onSecondary: Colors.white,
        surface: parchment,
        onSurface: deepCharcoal,
        outline: outline,
        surfaceContainerLow: surfaceLow,
      ),
      scaffoldBackgroundColor: parchment,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSerif(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          color: deepCharcoal,
          letterSpacing: -0.8,
        ),
        displayMedium: GoogleFonts.notoSerif(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: deepCharcoal,
        ),
        titleLarge: GoogleFonts.notoSerif(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: deepCharcoal,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: deepCharcoal,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: deepCharcoal,
          height: 1.6,
        ),
        labelSmall: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: deepCharcoal,
          letterSpacing: 0.65,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: parchment,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSerif(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: deepCharcoal,
        ),
        iconTheme: const IconThemeData(color: deepCharcoal),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: deepCharcoal.withAlpha(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: sageGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: sageGreen, width: 1),
        ),
      ),
    );
  }
}
