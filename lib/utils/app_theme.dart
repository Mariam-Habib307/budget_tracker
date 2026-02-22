import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
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
  static const Color danger = Color(0xFFE05555);
  static const Color success = Color(0xFF4CAF50);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          background: lightBg,
          surface: cardBg,
        ),
        scaffoldBackgroundColor: lightBg,
        textTheme: GoogleFonts.dmSansTextTheme().apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
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
      );

  static Color progressColor(double percent) {
    if (percent > 1.0) return danger;
    if (percent > 0.9) return coral;
    if (percent > 0.7) return const Color(0xFFE8C55C);
    return teal;
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

  static const List<Map<String, dynamic>> iconOptions = [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.restaurant_rounded, 'label': 'Food'},
    {'icon': Icons.directions_car_rounded, 'label': 'Car'},
    {'icon': Icons.local_hospital_rounded, 'label': 'Health'},
    {'icon': Icons.school_rounded, 'label': 'Education'},
    {'icon': Icons.shopping_bag_rounded, 'label': 'Shopping'},
    {'icon': Icons.flight_rounded, 'label': 'Travel'},
    {'icon': Icons.sports_esports_rounded, 'label': 'Games'},
    {'icon': Icons.fitness_center_rounded, 'label': 'Gym'},
    {'icon': Icons.receipt_long_rounded, 'label': 'Bills'},
    {'icon': Icons.pets_rounded, 'label': 'Pets'},
    {'icon': Icons.category_rounded, 'label': 'Other'},
  ];
}

class MoneyFormat {
  static String compact(double amount) {
    if (amount.abs() >= 1000) {
      return '£${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '£${amount.toStringAsFixed(0)}';
  }

  static String full(double amount) => '£${amount.toStringAsFixed(2)}';

  static String signed(double amount) {
    if (amount >= 0) return '+£${amount.toStringAsFixed(0)}';
    return '-£${(-amount).toStringAsFixed(0)}';
  }
}