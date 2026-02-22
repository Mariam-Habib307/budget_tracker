import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/budget_cubit.dart';
import '../models/budget_category.dart';
import '../utils/app_theme.dart';

class AddExpenseSheet extends StatefulWidget {
  final BudgetCategory category;

  const AddExpenseSheet({super.key, required this.category});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  double _amount = 0;

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(() {
      setState(() => _amount = double.tryParse(_amountCtrl.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _projected => widget.category.remainingAmount - _amount;

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    context
        .read<BudgetCubit>()
        .addExpense(widget.category.id, amount, _noteCtrl.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final isOver = _projected < 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: cat.color, borderRadius: BorderRadius.circular(14)),
                child: Icon(cat.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log Expense',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  Text(cat.title,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Live math preview
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isOver
                  ? AppTheme.danger.withOpacity(0.06)
                  : cat.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOver
                    ? AppTheme.danger.withOpacity(0.2)
                    : cat.color.withOpacity(0.2),
              ),
            ),
            child: Column(children: [
              _row('Budget', '£${cat.monthlyLimit.toStringAsFixed(0)}',
                  AppTheme.textPrimary),
              _row('Spent', '− £${cat.spentAmount.toStringAsFixed(0)}',
                  AppTheme.textSecondary),
              if (_amount > 0)
                _row("Today's Spending",
                    '− £${_amount.toStringAsFixed(0)}', cat.color),
              Divider(color: cat.color.withOpacity(0.15), height: 12),
              _row(
                'Remaining',
                isOver
                    ? '−£${(-_projected).toStringAsFixed(0)}'
                    : '£${_projected.toStringAsFixed(0)}',
                isOver ? AppTheme.danger : AppTheme.success,
                bold: true,
              ),
              if (isOver)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 13, color: AppTheme.danger),
                    const SizedBox(width: 4),
                    Text('Exceeds budget – will be logged anyway',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.danger)),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 16),

          _field(
            controller: _amountCtrl,
            label: 'Amount (£)',
            hint: '0.00',
            icon: Icons.attach_money_rounded,
            color: cat.color,
            type: const TextInputType.numberWithOptions(decimal: true),
            formatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
          ),
          const SizedBox(height: 10),
          _field(
            controller: _noteCtrl,
            label: 'Note (Optional)',
            hint: 'e.g. Groceries (Tesco)',
            icon: Icons.edit_note_rounded,
            color: cat.color,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: cat.color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Log Expense',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: valueColor,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    TextInputType? type,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.lightBg, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        keyboardType: type,
        inputFormatters: formatters,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: color, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle:
              const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}