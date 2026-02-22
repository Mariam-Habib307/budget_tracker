import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../utils/app_theme.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/transaction_tile.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        if (state is! BudgetLoaded) return const SizedBox.shrink();

        final cat = state.currentMonth.categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () {
            // Category was deleted while viewing — pop
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.pop(context));
            return state.currentMonth.categories.first;
          },
        );

        final transactions =
            state.currentMonth.transactionsForCategory(cat.id);
        final percent = cat.percentUsed.clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: AppTheme.lightBg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: cat.color,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: cat.color,
                    padding: const EdgeInsets.fromLTRB(24, 90, 24, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 55,
                              lineWidth: 9,
                              percent: percent,
                              center: Text(
                                '${(cat.percentUsed * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              progressColor: Colors.white,
                              backgroundColor:
                                  Colors.white.withOpacity(0.25),
                              circularStrokeCap: CircularStrokeCap.round,
                              animation: true,
                              animationDuration: 700,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cat.title,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white)),
                                  Text(
                                    'Budget – ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Colors.white.withOpacity(0.75)),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _stat('Spent',
                                          '£${cat.spentAmount.toStringAsFixed(0)}'),
                                      const SizedBox(width: 20),
                                      _stat('Limit',
                                          '£${cat.monthlyLimit.toStringAsFixed(0)}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Summary card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summStat('Spent',
                            '£${cat.spentAmount.toStringAsFixed(2)}', cat.color),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.grey.shade200),
                        _summStat(
                          'Remaining',
                          cat.isOverBudget
                              ? '−£${(-cat.remainingAmount).toStringAsFixed(2)}'
                              : '£${cat.remainingAmount.toStringAsFixed(2)}',
                          cat.isOverBudget
                              ? AppTheme.danger
                              : AppTheme.success,
                        ),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.grey.shade200),
                        _summStat('Transactions', '${transactions.length}',
                            AppTheme.textSecondary),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
                ),
              ),

              // Transactions label
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text('Transactions',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                ),
              ),

              // Transactions or empty
              transactions.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_rounded,
                                  size: 48,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              const Text('No expenses logged yet',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final t = transactions[i];
                            return TransactionTile(
                              transaction: t,
                              category: cat,
                              onDelete: () => context
                                  .read<BudgetCubit>()
                                  .deleteExpense(t.id),
                            )
                                .animate(
                                    delay: Duration(milliseconds: i * 40))
                                .fadeIn(duration: 250.ms)
                                .slideX(begin: 0.04);
                          },
                          childCount: transactions.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BlocProvider.value(
                value: context.read<BudgetCubit>(),
                child: AddExpenseSheet(category: cat),
              ),
            ),
            backgroundColor: cat.color,
            foregroundColor: Colors.white,
            elevation: 2,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Expense',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withOpacity(0.7))),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ],
      );

  Widget _summStat(String label, String value, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      );
}