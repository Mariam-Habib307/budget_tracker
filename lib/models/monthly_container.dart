import 'dart:convert';
import 'budget_category.dart';
import 'transaction.dart';

/// The key financial entity. Each month is fully independent.
/// Key format: "2026-02" (year-month, ISO-style, zero-padded).
class MonthlyContainer {
  final String monthKey; // e.g. "2026-02"
  final double monthIncome;
  final List<BudgetCategory> categories;
  final List<Transaction> transactions;

  MonthlyContainer({
    required this.monthKey,
    this.monthIncome = 0.0,
    required this.categories,
    required this.transactions,
  });

  // ── Derived values ──────────────────────────────────────────────────────────

  double get totalBudgeted =>
      categories.fold(0.0, (sum, c) => sum + c.monthlyLimit);

  double get totalSpent =>
      categories.fold(0.0, (sum, c) => sum + c.spentAmount);

  double get unallocatedFunds => monthIncome - totalBudgeted;

  double get remainingCash => monthIncome - totalSpent;

  List<Transaction> transactionsForCategory(String categoryId) =>
      transactions
          .where((t) => t.categoryId == categoryId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  // ── Copy ────────────────────────────────────────────────────────────────────

  MonthlyContainer copyWith({
    String? monthKey,
    double? monthIncome,
    List<BudgetCategory>? categories,
    List<Transaction>? transactions,
  }) {
    return MonthlyContainer(
      monthKey: monthKey ?? this.monthKey,
      monthIncome: monthIncome ?? this.monthIncome,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
    );
  }

  // ── Serialization ───────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'monthKey': monthKey,
        'monthIncome': monthIncome,
        'categories': categories.map((c) => c.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory MonthlyContainer.fromJson(Map<String, dynamic> json) =>
      MonthlyContainer(
        monthKey: json['monthKey'] as String,
        monthIncome: (json['monthIncome'] as num?)?.toDouble() ?? 0.0,
        categories: (json['categories'] as List<dynamic>)
            .map((e) => BudgetCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        transactions: (json['transactions'] as List<dynamic>)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Derives a fresh snapshot from a previous month's categories,
  /// resetting all spending to zero. Used for "Copy from Previous Month".
  MonthlyContainer copyBudgetsFrom(MonthlyContainer source, String newKey) {
    return MonthlyContainer(
      monthKey: newKey,
      monthIncome: source.monthIncome,
      categories: source.categories
          .map((c) => c.copyWith(spentAmount: 0.0))
          .toList(),
      transactions: [],
    );
  }

  static String keyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static DateTime dateFor(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Default categories when a brand-new month is created
  static MonthlyContainer empty(String monthKey) => MonthlyContainer(
        monthKey: monthKey,
        monthIncome: 0.0,
        categories: [],
        transactions: [],
      );
}