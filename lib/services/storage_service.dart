import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/monthly_container.dart';

/// Thin wrapper around a single Hive box.
/// Keys   → "2026-02" (MonthlyContainer.monthKey)
/// Values → JSON-encoded MonthlyContainer
class StorageService {
  static const _boxName = 'budget_months';
  late Box<String> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  // ── Read ─────────────────────────────────────────────────────────────────────

  MonthlyContainer? load(String monthKey) {
    final raw = _box.get(monthKey);
    if (raw == null) return null;
    try {
      return MonthlyContainer.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Returns all month keys that have been stored, sorted ascending.
  List<String> allMonthKeys() {
    final keys = _box.keys.cast<String>().toList();
    keys.sort();
    return keys;
  }

  // ── Write ────────────────────────────────────────────────────────────────────

  Future<void> save(MonthlyContainer container) async {
    await _box.put(container.monthKey, jsonEncode(container.toJson()));
  }

  Future<void> delete(String monthKey) async {
    await _box.delete(monthKey);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}