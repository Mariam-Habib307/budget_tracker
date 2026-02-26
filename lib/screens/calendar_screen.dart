import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../models/monthly_container.dart';
import '../models/transaction.dart';
import '../models/budget_category.dart';
import '../utils/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // The month being displayed in this calendar view.
  // Starts from whatever month the cubit is on.
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final state = context.read<BudgetCubit>().state;
    if (state is BudgetLoaded) {
      _displayMonth = MonthlyContainer.dateFor(state.currentMonth.monthKey);
    } else {
      _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);
    }
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
    context.read<BudgetCubit>().switchMonth(_displayMonth);
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
    context.read<BudgetCubit>().switchMonth(_displayMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {
          // Keep _displayMonth in sync when cubit switches month
          if (state is BudgetLoaded) {
            final cubitMonth =
                MonthlyContainer.dateFor(state.currentMonth.monthKey);
            if (cubitMonth.year != _displayMonth.year ||
                cubitMonth.month != _displayMonth.month) {
              setState(() => _displayMonth = cubitMonth);
            }
          }
        },
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.teal));
          }

          List<Transaction> transactions = [];
          List<BudgetCategory> categories = [];

          if (state is BudgetLoaded) {
            transactions = state.currentMonth.transactions;
            categories = state.currentMonth.categories;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              children: [
                _MonthHeader(
                  month: _displayMonth,
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                ),
                const SizedBox(height: 16),
                _CalendarGrid(
                  displayMonth: _displayMonth,
                  transactions: transactions,
                  categories: categories,
                ),
                const SizedBox(height: 20),
                if (state is BudgetLoaded)
                  _MonthSummaryBar(month: state.currentMonth),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Month header with prev/next ─────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader(
      {required this.month, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = month.year == DateTime.now().year &&
        month.month == DateTime.now().month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Column(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (isCurrentMonth) ...[
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.teal,
                    ),
                  ),
                ),
              ],
            ],
          ),
          _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 22),
      ),
    );
  }
}

// ─── Calendar Grid ────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final DateTime displayMonth;
  final List<Transaction> transactions;
  final List<BudgetCategory> categories;

  const _CalendarGrid({
    required this.displayMonth,
    required this.transactions,
    required this.categories,
  });

  /// Returns a map of day-of-month → list of transactions for that day
  Map<int, List<Transaction>> get _txByDay {
    final map = <int, List<Transaction>>{};
    for (final tx in transactions) {
      if (tx.date.year == displayMonth.year &&
          tx.date.month == displayMonth.month) {
        map.putIfAbsent(tx.date.day, () => []).add(tx);
      }
    }
    return map;
  }

  Color _categoryColor(String catId) {
    try {
      return categories.firstWhere((c) => c.id == catId).color;
    } catch (_) {
      return AppTheme.teal;
    }
  }

  String _categoryName(String catId) {
    try {
      return categories.firstWhere((c) => c.id == catId).title;
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final txByDay = _txByDay;

    // First weekday of the month (Monday-based, 0=Mon … 6=Sun)
    final firstDay = DateTime(displayMonth.year, displayMonth.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7; // Mon=0, Sun=6

    // Number of days in the month
    final daysInMonth =
        DateTime(displayMonth.year, displayMonth.month + 1, 0).day;

    final today = DateTime.now();
    final isThisMonth =
        today.year == displayMonth.year && today.month == displayMonth.month;

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: weekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),

          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox.shrink();
              }
              final day = index - startOffset + 1;
              final isToday = isThisMonth && day == today.day;
              final dayTxs = txByDay[day] ?? [];

              return _DayCell(
                day: day,
                isToday: isToday,
                transactions: dayTxs,
                onTap: dayTxs.isNotEmpty
                    ? () => _showDaySheet(
                          context,
                          day,
                          dayTxs,
                        )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDaySheet(BuildContext context, int day, List<Transaction> dayTxs) {
    final date = DateTime(displayMonth.year, displayMonth.month, day);
    final dateLabel = DateFormat('EEEE, d MMMM yyyy').format(date);
    final total = dayTxs.fold(0.0, (sum, t) => sum + t.amount);

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${dayTxs.length} transaction${dayTxs.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '£${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: dayTxs.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (_, i) {
                    final tx = dayTxs[i];
                    final catColor = _categoryColor(tx.categoryId);
                    final catName = _categoryName(tx.categoryId);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: catColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  catName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (tx.note.isNotEmpty)
                                  Text(
                                    tx.note,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '£${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: catColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Day Cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final List<Transaction> transactions;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.transactions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasTx = transactions.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isToday ? AppTheme.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: hasTx && !isToday
              ? Border.all(color: AppTheme.teal.withOpacity(0.25), width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: isToday ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            if (hasTx) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < transactions.length.clamp(0, 3); i++)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.white.withOpacity(0.8)
                            : AppTheme.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Month Summary Bar ────────────────────────────────────────────────────────

class _MonthSummaryBar extends StatelessWidget {
  final MonthlyContainer month;

  const _MonthSummaryBar({required this.month});

  @override
  Widget build(BuildContext context) {
    final spent = month.totalSpent;
    final income = month.monthIncome;
    final remaining = income - spent;
    final pct = income > 0 ? (spent / income).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Month Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${(pct * 100).toStringAsFixed(0)}% spent',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppTheme.surface,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppTheme.progressColor(pct)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(
                  label: 'Income',
                  value: '£${income.toStringAsFixed(0)}',
                  color: AppTheme.teal),
              _SummaryItem(
                  label: 'Spent',
                  value: '£${spent.toStringAsFixed(0)}',
                  color: AppTheme.coral),
              _SummaryItem(
                  label: 'Left',
                  value: remaining >= 0
                      ? '£${remaining.toStringAsFixed(0)}'
                      : '-£${(-remaining).toStringAsFixed(0)}',
                  color: remaining >= 0 ? AppTheme.success : AppTheme.danger),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}
