import 'package:equatable/equatable.dart';
import '../models/monthly_container.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();
  @override
  List<Object?> get props => [];
}

/// Before any data has been loaded
class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

/// Transitioning between months or first load
class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

/// Active state: one month is in focus, all month keys are known
class BudgetLoaded extends BudgetState {
  final MonthlyContainer currentMonth;
  final List<String> availableMonthKeys; // sorted ascending

  const BudgetLoaded({
    required this.currentMonth,
    required this.availableMonthKeys,
  });

  BudgetLoaded copyWith({
    MonthlyContainer? currentMonth,
    List<String>? availableMonthKeys,
  }) {
    return BudgetLoaded(
      currentMonth: currentMonth ?? this.currentMonth,
      availableMonthKeys: availableMonthKeys ?? this.availableMonthKeys,
    );
  }

  @override
  List<Object?> get props => [currentMonth, availableMonthKeys];
}

/// Recoverable error — the UI re-emits the previous loaded state after showing
class BudgetError extends BudgetState {
  final String message;
  const BudgetError(this.message);
  @override
  List<Object?> get props => [message];
}