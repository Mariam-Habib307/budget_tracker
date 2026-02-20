import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../utils/app_theme.dart';
import '../widgets/budget_card.dart';
import 'category_detail_screen.dart';
import 'add_budget_screen.dart';

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
                backgroundColor: const Color(0xFFE05555),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BudgetLoaded) {
            return _buildDashboard(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
        ),
        backgroundColor: AppTheme.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, BudgetLoaded state) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(now);

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(context, state, monthLabel),
        ),

        // Grid title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showResetDialog(context),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset Month'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    textStyle:
                        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Budget cards grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cat = state.categories[index];
                return BudgetCard(
                  category: cat,
                  index: index,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailScreen(category: cat),
                      ),
                    );
                  },
                );
              },
              childCount: state.categories.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, BudgetLoaded state, String monthLabel) {
    final spentPercent =
        state.totalBudget > 0 ? state.totalSpent / state.totalBudget : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        color: AppTheme.teal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthLabel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 500.ms),
                      const SizedBox(height: 2),
                      Text(
                        'Monthly Overview',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _statPill(
                    'Spent',
                    '£${state.totalSpent.toStringAsFixed(0)}',
                    Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(width: 10),
                  _statPill(
                    'Budget',
                    '£${state.totalBudget.toStringAsFixed(0)}',
                    Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(width: 10),
                  _statPill(
                    'Left',
                    '£${state.totalRemaining.toStringAsFixed(0)}',
                    Colors.white.withOpacity(0.2),
                    highlight: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: spentPercent.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    spentPercent > 0.9
                        ? const Color(0xFFE8845C)
                        : Colors.white,
                  ),
                ),
              ).animate().slideX(begin: -0.2, end: 0, duration: 600.ms),
              const SizedBox(height: 6),
              Text(
                '${(spentPercent * 100).toStringAsFixed(0)}% of budget used',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statPill(String label, String value, Color bg,
      {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Month?'),
        content: const Text(
          'This will clear all spending data and transactions for the month. Categories will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BudgetCubit>().resetMonthlyBudgets();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE05555),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
