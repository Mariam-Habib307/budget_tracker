import 'package:flutter/material.dart';

/// Central registry that maps string keys to CONSTANT IconData values.
///
/// WHY THIS EXISTS:
/// Flutter's release build tree-shaker requires all IconData references to be
/// compile-time constants. Storing IconData (or reconstructing it from an int
/// codepoint) at runtime breaks tree-shaking and fails `flutter build apk --release`.
///
/// Solution: store a plain String key in the model layer, resolve it to a
/// constant IconData here at the UI layer only.
class IconRegistry {
  IconRegistry._();

  /// All available category icons.
  /// Key   → stored in BudgetCategory.iconKey (persisted to disk)
  /// Value → compile-time constant IconData (safe for release builds)
  static const Map<String, IconData> _icons = {
    'home':          Icons.home_rounded,
    'food':          Icons.restaurant_rounded,
    'car':           Icons.directions_car_rounded,
    'health':        Icons.local_hospital_rounded,
    'education':     Icons.school_rounded,
    'shopping':      Icons.shopping_bag_rounded,
    'travel':        Icons.flight_rounded,
    'entertainment': Icons.sports_esports_rounded,
    'gym':           Icons.fitness_center_rounded,
    'bills':         Icons.receipt_long_rounded,
    'pets':          Icons.pets_rounded,
    'other':         Icons.category_rounded,
  };

  /// Resolve a key to its IconData. Falls back to 'other' if key is unknown.
  static IconData resolve(String key) =>
      _icons[key] ?? Icons.category_rounded;

  /// All entries for use in pickers.
  static List<MapEntry<String, IconData>> get all => _icons.entries.toList();

  /// Human-readable label for a key.
  static const Map<String, String> _labels = {
    'home':          'Home',
    'food':          'Food',
    'car':           'Car',
    'health':        'Health',
    'education':     'Education',
    'shopping':      'Shopping',
    'travel':        'Travel',
    'entertainment': 'Entertainment',
    'gym':           'Gym',
    'bills':         'Bills',
    'pets':          'Pets',
    'other':         'Other',
  };

  static String label(String key) => _labels[key] ?? 'Other';
}