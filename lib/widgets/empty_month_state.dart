import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/monthly_container.dart';
import '../utils/app_theme.dart';

class EmptyMonthState extends StatelessWidget {
  final String monthKey;
  final bool hasPreviousData;
  final VoidCallback onCopyPrevious;
  final VoidCallback onAddCategory;

  const EmptyMonthState({
    super.key,
    required this.monthKey,
    required this.hasPreviousData,
    required this.onCopyPrevious,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    final date = MonthlyContainer.dateFor(monthKey);
    final monthName = DateFormat('MMMM yyyy').format(date);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 44,
                color: AppTheme.teal,
              ),
            )
                .animate()
                .scale(delay: 100.ms, duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              monthName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 8),
            Text(
              'No budgets set for this month yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),
            if (hasPreviousData) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCopyPrevious,
                  icon: const Icon(Icons.content_copy_rounded, size: 18),
                  label: const Text('Copy Budgets from Previous Month'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddCategory,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Start Fresh — Add Category'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.teal,
                  side: const BorderSide(color: AppTheme.teal),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}