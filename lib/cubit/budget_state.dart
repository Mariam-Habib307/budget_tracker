import 'package:equatable/equatable.dart';
import '../models/budget_category.dart';
import '../models/transaction.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetLoaded extends BudgetState {
  final List<BudgetCategory> categories;
  final List<Transaction> transactions;

  const BudgetLoaded({
    required this.categories,
    required this.transactions,
  });

  double get totalBudget =>
      categories.fold(0, (sum, c) => sum + c.monthlyLimit);
  double get totalSpent =>
      categories.fold(0, (sum, c) => sum + c.spentAmount);
  double get totalRemaining => totalBudget - totalSpent;

  List<Transaction> transactionsForCategory(String categoryId) =>
      transactions.where((t) => t.categoryId == categoryId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  BudgetLoaded copyWith({
    List<BudgetCategory>? categories,
    List<Transaction>? transactions,
  }) {
    return BudgetLoaded(
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [categories, transactions];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}
