import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../models/budget_category.dart';
import '../utils/app_theme.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/transaction_tile.dart';

class CategoryDetailScreen extends StatelessWidget {
  final BudgetCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        if (state is! BudgetLoaded) return const SizedBox.shrink();

        final cat = state.categories.firstWhere(
          (c) => c.id == category.id,
          orElse: () => category,
        );
        final transactions = state.transactionsForCategory(cat.id);
        final percent = cat.percentUsed.clamp(0.0, 1.0);
        final progressColor = AppTheme.progressColor(cat.percentUsed);

        return Scaffold(
          backgroundColor: AppTheme.lightBg,
          body: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: cat.color,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(context, cat);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded,
                                color: Color(0xFFE05555), size: 18),
                            SizedBox(width: 8),
                            Text('Delete Category'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: cat.color,
                    padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 60,
                              lineWidth: 10,
                              percent: percent,
                              center: Text(
                                '${(cat.percentUsed * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              progressColor: Colors.white,
                              backgroundColor: Colors.white.withOpacity(0.25),
                              circularStrokeCap: CircularStrokeCap.round,
                              animation: true,
                              animationDuration: 800,
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Budget – ${DateFormat('MMMM').format(DateTime.now())}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _miniStat('Spent',
                                          '£${cat.spentAmount.toStringAsFixed(0)}'),
                                      const SizedBox(width: 16),
                                      _miniStat('Budget',
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

              // Remaining card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _detailStat('Spent', '£${cat.spentAmount.toStringAsFixed(2)}',
                            cat.color),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _detailStat(
                          'Remaining',
                          cat.isOverBudget
                              ? '-£${(-cat.remainingAmount).toStringAsFixed(2)}'
                              : '£${cat.remainingAmount.toStringAsFixed(2)}',
                          cat.isOverBudget
                              ? const Color(0xFFE05555)
                              : const Color(0xFF4CAF50),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _detailStat('Transactions', '${transactions.length}',
                            AppTheme.textSecondary),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                ),
              ),

              // Transactions header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Text(
                    'Transactions',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),

              // Transaction list
              transactions.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_rounded,
                                  size: 52, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text(
                                'No transactions yet',
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final t = transactions[index];
                            return TransactionTile(
                              transaction: t,
                              category: cat,
                              onDelete: () {
                                context
                                    .read<BudgetCubit>()
                                    .deleteExpense(t.id);
                              },
                            )
                                .animate(
                                    delay: Duration(milliseconds: index * 50))
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.05, end: 0);
                          },
                          childCount: transactions.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: context.read<BudgetCubit>(),
                  child: AddExpenseSheet(category: cat),
                ),
              );
            },
            backgroundColor: cat.color,
            foregroundColor: Colors.white,
            elevation: 2,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Expense',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _detailStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, BudgetCategory cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete ${cat.title}?'),
        content: const Text(
          'This will permanently delete the category and all its transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BudgetCubit>().deleteCategory(cat.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE05555),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
