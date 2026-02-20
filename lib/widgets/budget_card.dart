import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/budget_category.dart';
import '../utils/app_theme.dart';

class BudgetCard extends StatelessWidget {
  final BudgetCategory category;
  final VoidCallback onTap;
  final int index;

  const BudgetCard({
    super.key,
    required this.category,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final percent = category.percentUsed.clamp(0.0, 1.0);
    final progressColor = AppTheme.progressColor(category.percentUsed);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: category.isOverBudget
                ? const Color(0xFFE05555).withOpacity(0.4)
                : category.color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                if (category.isOverBudget)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE05555).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Over!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE05555),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              category.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'of £${category.monthlyLimit.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            Center(
              child: CircularPercentIndicator(
                radius: 44,
                lineWidth: 8,
                percent: percent,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '£${category.spentAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
                progressColor: progressColor,
                backgroundColor: progressColor.withOpacity(0.15),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  category.isOverBudget
                      ? '-£${(-category.remainingAmount).toStringAsFixed(0)}'
                      : '£${category.remainingAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: category.isOverBudget
                        ? const Color(0xFFE05555)
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
