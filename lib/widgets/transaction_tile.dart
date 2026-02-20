import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/budget_category.dart';
import '../utils/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final BudgetCategory category;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE05555).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Color(0xFFE05555)),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.note.isEmpty ? category.title : transaction.note,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, HH:mm').format(transaction.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-£${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE05555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
