import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette inspired by the design mockup
  static const Color teal = Color(0xFF5BA4A4);
  static const Color coral = Color(0xFFE8845C);
  static const Color mint = Color(0xFF7EB8A4);
  static const Color amber = Color(0xFFE8A55C);
  static const Color navy = Color(0xFF1E2D3D);
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E2D3D);
  static const Color textSecondary = Color(0xFF8A9BB0);
  static const Color surface = Color(0xFFEEF2F7);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          background: lightBg,
          surface: cardBg,
        ),
        scaffoldBackgroundColor: lightBg,
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          displayLarge: GoogleFonts.dmSans(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          displayMedium: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleLarge: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyMedium: GoogleFonts.dmSans(
            fontSize: 14,
            color: textSecondary,
          ),
          labelLarge: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        cardTheme: CardTheme(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  static Color progressColor(double percent) {
    if (percent > 1.0) return const Color(0xFFE05555);
    if (percent > 0.9) return const Color(0xFFE8845C);
    if (percent > 0.7) return const Color(0xFFE8C55C);
    return const Color(0xFF5BA4A4);
  }

  static List<Color> categoryColors = [
    const Color(0xFF5BA4A4),
    const Color(0xFFE8845C),
    const Color(0xFF7EB8A4),
    const Color(0xFFE8A55C),
    const Color(0xFF8B7FC7),
    const Color(0xFFE87C7C),
    const Color(0xFF5B8FA4),
    const Color(0xFFA4845B),
  ];
}

class CurrencyFormatter {
  static String format(double amount) {
    if (amount >= 1000) {
      return '£${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '£${amount.toStringAsFixed(0)}';
  }

  static String formatFull(double amount) {
    return '£${amount.toStringAsFixed(2)}';
  }
}
