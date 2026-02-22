import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_category.dart';
import '../models/monthly_container.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final StorageService _storage;
  final _uuid = const Uuid();

  BudgetCubit(this._storage) : super(const BudgetInitial());

  // ── Bootstrap ──────────────────────────────────────────────────────────────

  Future<void> loadCurrentMonth() async {
    emit(const BudgetLoading());
    try {
      final currentKey = MonthlyContainer.keyFor(DateTime.now());
      var container = _storage.load(currentKey);

      // First ever launch → seed with default categories
      if (container == null) {
        container = MonthlyContainer(
          monthKey: currentKey,
          monthIncome: 0.0,
          categories: _defaultCategories(),
          transactions: [],
        );
        await _storage.save(container);
      }

      final keys = _ensureKeyPresent(_storage.allMonthKeys(), currentKey);
      emit(BudgetLoaded(currentMonth: container, availableMonthKeys: keys));
    } catch (e) {
      emit(BudgetError('Failed to load data: $e'));
    }
  }

  // ── Month navigation ───────────────────────────────────────────────────────

  Future<void> switchMonth(DateTime date) async {
    final loaded = _requireLoaded();
    if (loaded == null) return;

    final key = MonthlyContainer.keyFor(date);
    emit(const BudgetLoading());

    try {
      var container = _storage.load(key);
      if (container == null) {
        // New month — emit as empty; caller UI will offer "Copy" option
        container = MonthlyContainer.empty(key);
        // Don't persist yet; only persist when user takes an action
      }

      final keys = _ensureKeyPresent(loaded.availableMonthKeys, key);
      emit(BudgetLoaded(currentMonth: container, availableMonthKeys: keys));
    } catch (e) {
      emit(BudgetError('Failed to switch month: $e'));
      emit(loaded);
    }
  }

  /// Copy category definitions (zeroed spending) from the previous month.
  Future<void> copyBudgetsFromPreviousMonth() async {
    final loaded = _requireLoaded();
    if (loaded == null) return;

    // Find the closest earlier month key
    final currentKey = loaded.currentMonth.monthKey;
    final allKeys = List<String>.from(loaded.availableMonthKeys)..sort();
    final previousKey = allKeys
        .where((k) => k.compareTo(currentKey) < 0 && _storage.load(k) != null)
        .lastOrNull;

    if (previousKey == null) {
      _emitError(loaded, 'No previous month data found to copy from.');
      return;
    }

    final previous = _storage.load(previousKey)!;
    final newContainer =
        loaded.currentMonth.copyBudgetsFrom(previous, currentKey);
    await _storage.save(newContainer);

    final keys = _ensureKeyPresent(loaded.availableMonthKeys, currentKey);
    emit(BudgetLoaded(
        currentMonth: newContainer, availableMonthKeys: keys));
  }

  // ── Income ─────────────────────────────────────────────────────────────────

  Future<void> updateIncome(double newIncome) async {
    final loaded = _requireLoaded();
    if (loaded == null) return;

    if (newIncome < 0) {
      _emitError(loaded, 'Income cannot be negative.');
      return;
    }

    final updated = loaded.currentMonth.copyWith(monthIncome: newIncome);
    await _persistAndEmit(loaded, updated);
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  Future<void> addCustomBudget(
      String title, double limit, IconData icon, Color color) async {
    final loaded = _requireLoaded();
    if (loaded == null) return;

    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      _emitError(loaded, 'Category title cannot be empty.');
      return;
    }
    if (limit <= 0) {
      _emitError(loaded, 'Budget limit must be greater than zero.');
      return;
    }
    final exists = loaded.currentMonth.categories
        .any((c) => c.title.toLowerCase() == trimmed.toLowerCase());
    if (exists) {
      _emitError(loaded, 'A category with this title already exists.');
      return;
    }

    final newCat = BudgetCategory(
      id: _uuid.v4(),
      title: trimmed,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
      monthlyLimit: limit,
      color: color,
    );

    final updated = loaded.currentMonth.copyWith(
      categories: [...loaded.currentMonth.categories, newCat],
    );
    await _persistAndEmit(loaded, updated);
  }

  /// Long-press inline edit: update only this month's limit for the category.
  Future<void> updateCategoryLimit(
      String categoryId, double newLimit) async {
    final loaded = _requireLoaded();
    if (loaded == null) return;

    if (newLimit <= 0) {
      _emitError(loaded, 'Budget limit must be greater than zero.');
      return;
    }

    final updatedCats = loaded.currentMonth.categories.map((c) {
      if (c.id == categoryId) return c.copyWith(monthlyLimit: newLimit);
      return c;
    }).toList();

    final updated =
        loaded.currentMonth.copyWith(categories: updatedCats);
    await _persistAndEmit(loaded, updated);
  }

  /// Deletes category AND all its transactions for the current month only.
  Future<void> deleteCategory(String categoryId) async {
    final loaded = _requireLoaded();
    if (loaded == null) return;

    final updatedCats = loaded.currentMonth.categories
        .where((c) => c.id != categoryId)
        .toList();

    // Data integrity: also remove all linked transactions
    final updatedTxns = loaded.currentMonth.transactions
        .where((t) => t.categoryId != categoryId)
        .toList();

    final updated = loaded.currentMonth.copyWith(
      categories: updatedCats,
      transactions: updatedTxns,
    );
    await _persistAndEmit(loaded, updated);
  }

  // ── Expenses ───────────────────────────────────────────────────────────────

  Future<void> addExpense(
      String categoryId, double amount, String note) async {
    final loaded = _requireLoaded();
    if (loaded == null) return;

    if (amount <= 0) {
      _emitError(loaded, 'Amount must be greater than zero.');
      return;
    }

    final txn = Transaction(
      id: _uuid.v4(),
      categoryId: categoryId,
      amount: amount,
      note: note.trim(),
      date: DateTime.now(),
    );

    final updatedCats = loaded.currentMonth.categories.map((c) {
      if (c.id == categoryId) {
        return c.copyWith(spentAmount: c.spentAmount + amount);
      }
      return c;
    }).toList();

    final updated = loaded.currentMonth.copyWith(
      categories: updatedCats,
      transactions: [...loaded.currentMonth.transactions, txn],
    );
    await _persistAndEmit(loaded, updated);
  }

  Future<void> deleteExpense(String transactionId) async {
    final loaded = _requireLoaded();
    if (loaded == null) return;

    try {
      final txn = loaded.currentMonth.transactions
          .firstWhere((t) => t.id == transactionId);

      final updatedTxns = loaded.currentMonth.transactions
          .where((t) => t.id != transactionId)
          .toList();

      final updatedCats = loaded.currentMonth.categories.map((c) {
        if (c.id == txn.categoryId) {
          final newSpent =
              (c.spentAmount - txn.amount).clamp(0.0, double.infinity);
          return c.copyWith(spentAmount: newSpent);
        }
        return c;
      }).toList();

      final updated = loaded.currentMonth.copyWith(
        categories: updatedCats,
        transactions: updatedTxns,
      );
      await _persistAndEmit(loaded, updated);
    } catch (e) {
      _emitError(loaded, 'Transaction not found.');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  BudgetLoaded? _requireLoaded() {
    final s = state;
    if (s is BudgetLoaded) return s;
    return null;
  }

  Future<void> _persistAndEmit(
      BudgetLoaded prev, MonthlyContainer updated) async {
    await _storage.save(updated);
    final keys =
        _ensureKeyPresent(prev.availableMonthKeys, updated.monthKey);
    emit(prev.copyWith(currentMonth: updated, availableMonthKeys: keys));
  }

  void _emitError(BudgetLoaded prev, String message) {
    emit(BudgetError(message));
    emit(prev); // restore immediately so UI can react
  }

  List<String> _ensureKeyPresent(List<String> keys, String key) {
    final set = {...keys, key}.toList()..sort();
    return set;
  }

  List<BudgetCategory> _defaultCategories() => [
        BudgetCategory(
          id: 'home',
          title: 'Home',
          iconCodePoint: Icons.home_rounded.codePoint,
          monthlyLimit: 500,
          color: const Color(0xFF5BA4A4),
        ),
        BudgetCategory(
          id: 'food',
          title: 'Food',
          iconCodePoint: Icons.restaurant_rounded.codePoint,
          monthlyLimit: 300,
          color: const Color(0xFFE8845C),
        ),
        BudgetCategory(
          id: 'transport',
          title: 'Transport',
          iconCodePoint: Icons.directions_car_rounded.codePoint,
          monthlyLimit: 200,
          color: const Color(0xFF7EB8A4),
        ),
        BudgetCategory(
          id: 'bills',
          title: 'Bills',
          iconCodePoint: Icons.receipt_long_rounded.codePoint,
          monthlyLimit: 150,
          color: const Color(0xFFE8A55C),
        ),
      ];
}