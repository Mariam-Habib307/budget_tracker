import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_category.dart';
import '../models/transaction.dart';
import 'budget_state.dart';

class BudgetCubit extends HydratedCubit<BudgetState> {
  final _uuid = const Uuid();

  BudgetCubit() : super(const BudgetInitial());

  static List<BudgetCategory> get defaultCategories => [
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

  void loadBudgets() {
    try {
      emit(const BudgetLoading());
      // HydratedBloc auto-restores state; if no persisted state, load defaults
      if (state is BudgetLoading) {
        emit(BudgetLoaded(
          categories: defaultCategories,
          transactions: [],
        ));
      }
    } catch (e) {
      emit(BudgetError('Failed to load budgets: $e'));
    }
  }

  void addCustomBudget(String title, double limit, IconData icon, Color color) {
    try {
      final current = state;
      if (current is! BudgetLoaded) return;

      final trimmed = title.trim();
      if (trimmed.isEmpty) {
        emit(BudgetError('Category title cannot be empty'));
        emit(current);
        return;
      }
      if (limit <= 0) {
        emit(BudgetError('Budget limit must be greater than zero'));
        emit(current);
        return;
      }
      final exists = current.categories.any(
        (c) => c.title.toLowerCase() == trimmed.toLowerCase(),
      );
      if (exists) {
        emit(BudgetError('A category with this title already exists'));
        emit(current);
        return;
      }

      final newCategory = BudgetCategory(
        id: _uuid.v4(),
        title: trimmed,
        iconCodePoint: icon.codePoint,
        iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
        monthlyLimit: limit,
        color: color,
      );

      emit(current.copyWith(
        categories: [...current.categories, newCategory],
      ));
    } catch (e) {
      emit(BudgetError('Failed to add category: $e'));
    }
  }

  void addExpense(String categoryId, double amount, String note) {
    try {
      final current = state;
      if (current is! BudgetLoaded) return;

      if (amount <= 0) {
        emit(BudgetError('Amount must be greater than zero'));
        emit(current);
        return;
      }

      final transaction = Transaction(
        id: _uuid.v4(),
        categoryId: categoryId,
        amount: amount,
        note: note.trim(),
        date: DateTime.now(),
      );

      final updatedCategories = current.categories.map((cat) {
        if (cat.id == categoryId) {
          return cat.copyWith(spentAmount: cat.spentAmount + amount);
        }
        return cat;
      }).toList();

      emit(current.copyWith(
        categories: updatedCategories,
        transactions: [...current.transactions, transaction],
      ));
    } catch (e) {
      emit(BudgetError('Failed to add expense: $e'));
    }
  }

  void deleteExpense(String transactionId) {
    try {
      final current = state;
      if (current is! BudgetLoaded) return;

      final transaction = current.transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      final updatedTransactions =
          current.transactions.where((t) => t.id != transactionId).toList();

      final updatedCategories = current.categories.map((cat) {
        if (cat.id == transaction.categoryId) {
          final newSpent =
              (cat.spentAmount - transaction.amount).clamp(0.0, double.infinity);
          return cat.copyWith(spentAmount: newSpent);
        }
        return cat;
      }).toList();

      emit(current.copyWith(
        categories: updatedCategories,
        transactions: updatedTransactions,
      ));
    } catch (e) {
      emit(BudgetError('Failed to delete expense: $e'));
    }
  }

  void resetMonthlyBudgets() {
    final current = state;
    if (current is! BudgetLoaded) return;

    final resetCategories =
        current.categories.map((c) => c.copyWith(spentAmount: 0.0)).toList();

    emit(current.copyWith(
      categories: resetCategories,
      transactions: [],
    ));
  }

  void deleteCategory(String categoryId) {
    final current = state;
    if (current is! BudgetLoaded) return;

    final updatedCategories =
        current.categories.where((c) => c.id != categoryId).toList();
    final updatedTransactions =
        current.transactions.where((t) => t.categoryId != categoryId).toList();

    emit(current.copyWith(
      categories: updatedCategories,
      transactions: updatedTransactions,
    ));
  }

  // ── HydratedBloc serialization ────────────────────────────────────────────

  @override
  BudgetState? fromJson(Map<String, dynamic> json) {
    try {
      final cats = (json['categories'] as List)
          .map((e) => BudgetCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      final txns = (json['transactions'] as List)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();

      // Auto-reset if month changed
      final savedMonth = json['month'] as int?;
      final now = DateTime.now();
      if (savedMonth != null && savedMonth != now.month) {
        final reset = cats.map((c) => c.copyWith(spentAmount: 0.0)).toList();
        return BudgetLoaded(categories: reset, transactions: []);
      }

      return BudgetLoaded(categories: cats, transactions: txns);
    } catch (_) {
      return BudgetLoaded(categories: defaultCategories, transactions: []);
    }
  }

  @override
  Map<String, dynamic>? toJson(BudgetState state) {
    if (state is BudgetLoaded) {
      return {
        'categories': state.categories.map((c) => c.toJson()).toList(),
        'transactions': state.transactions.map((t) => t.toJson()).toList(),
        'month': DateTime.now().month,
      };
    }
    return null;
  }
}
