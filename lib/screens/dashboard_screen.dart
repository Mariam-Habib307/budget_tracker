import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../models/monthly_container.dart';
import '../utils/app_theme.dart';
import '../widgets/month_picker_strip.dart';
import '../widgets/income_header.dart';
import '../widgets/budget_card.dart';
import '../widgets/empty_month_state.dart';
import 'category_detail_screen.dart';
import 'add_budget_screen.dart';
import 'calendar_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {
          if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.teal));
          }
          if (state is BudgetLoaded) {
            return _buildBody(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BudgetLoaded state) {
    final month = state.currentMonth;
    final isEmpty = month.categories.isEmpty;
    final monthLabel = DateFormat('MMMM yyyy')
        .format(MonthlyContainer.dateFor(month.monthKey));
    final isCurrentMonth =
        month.monthKey == MonthlyContainer.keyFor(DateTime.now());

    // Check if previous data exists for "Copy" feature
    final hasPrevious = state.availableMonthKeys
        .where((k) => k.compareTo(month.monthKey) < 0)
        .any((k) => true);

    return Column(
      children: [
        // ── App bar ─────────────────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BudgetFlow',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      monthLabel,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (!isCurrentMonth)
                      GestureDetector(
                        onTap: () => context
                            .read<BudgetCubit>()
                            .switchMonth(DateTime.now()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Today',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.teal)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Calendar button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CalendarScreen()),
                      ),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_month_rounded,
                            color: AppTheme.teal, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add budget button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddBudgetScreen()),
                      ),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Month picker ────────────────────────────────────────────────────
        const SizedBox(height: 12),
        MonthPickerStrip(
          currentMonthKey: month.monthKey,
          availableKeys: state.availableMonthKeys,
          onMonthSelected: (date) =>
              context.read<BudgetCubit>().switchMonth(date),
        ),
        const SizedBox(height: 16),

        // ── Scrollable content ──────────────────────────────────────────────
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: isEmpty
                ? EmptyMonthState(
                    key: ValueKey('empty_${month.monthKey}'),
                    monthKey: month.monthKey,
                    hasPreviousData: hasPrevious,
                    onCopyPrevious: () => context
                        .read<BudgetCubit>()
                        .copyBudgetsFromPreviousMonth(),
                    onAddCategory: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddBudgetScreen()),
                    ),
                  )
                : _buildContent(context, state),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, BudgetLoaded state) {
    final month = state.currentMonth;

    return CustomScrollView(
      key: ValueKey('loaded_${month.monthKey}'),
      slivers: [
        // Income header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: IncomeHeader(
              income: month.monthIncome,
              totalBudgeted: month.totalBudgeted,
              totalSpent: month.totalSpent,
              onIncomeChanged: (v) =>
                  context.read<BudgetCubit>().updateIncome(v),
            ).animate().fadeIn(duration: 300.ms),
          ),
        ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${month.categories.length} Categories',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Long-press to edit',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),

        // Category cards grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.76,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cat = month.categories[index];
                return BudgetCard(
                  category: cat,
                  index: index,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        categoryId: cat.id,
                      ),
                    ),
                  ),
                  onLimitChanged: (newLimit) => context
                      .read<BudgetCubit>()
                      .updateCategoryLimit(cat.id, newLimit),
                  onDelete: () => _confirmDelete(context, cat.id, cat.title),
                );
              },
              childCount: month.categories.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _confirmDelete(BuildContext ctx, String catId, String title) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "$title"?'),
        content: const Text(
          'This removes the category and all its transactions for this month only. Other months are not affected.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ctx.read<BudgetCubit>().deleteCategory(catId);
              Navigator.pop(dCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete This Month'),
          ),
        ],
      ),
    );
  }
}
