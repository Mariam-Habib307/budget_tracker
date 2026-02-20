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
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  double _enteredAmount = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        _enteredAmount = double.tryParse(_amountController.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _projectedRemaining =>
      widget.category.remainingAmount - _enteredAmount;

  void _submit() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    context.read<BudgetCubit>().addExpense(
          widget.category.id,
          amount,
          _noteController.text,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final isOver = _projectedRemaining < 0;

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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cat.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(cat.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Expense',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    cat.title,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Live math preview
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOver
                  ? const Color(0xFFE05555).withOpacity(0.08)
                  : cat.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOver
                    ? const Color(0xFFE05555).withOpacity(0.2)
                    : cat.color.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _mathRow('Budget', '£${cat.monthlyLimit.toStringAsFixed(0)}',
                    AppTheme.textPrimary),
                _mathRow(
                    'Spent', '- £${cat.spentAmount.toStringAsFixed(0)}', AppTheme.textSecondary),
                if (_enteredAmount > 0)
                  _mathRow(
                    "Today's Spending",
                    '- £${_enteredAmount.toStringAsFixed(0)}',
                    cat.color,
                  ),
                Divider(
                  color: cat.color.withOpacity(0.2),
                  height: 16,
                ),
                _mathRow(
                  'Remaining',
                  isOver
                      ? '-£${(-_projectedRemaining).toStringAsFixed(0)}'
                      : '£${_projectedRemaining.toStringAsFixed(0)}',
                  isOver ? const Color(0xFFE05555) : const Color(0xFF4CAF50),
                  bold: true,
                ),
                if (isOver)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_rounded,
                            size: 14, color: Color(0xFFE05555)),
                        const SizedBox(width: 4),
                        Text(
                          'This will exceed your budget',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFE05555),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount field
          _buildTextField(
            controller: _amountController,
            label: 'Amount (£)',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            prefixIcon: Icons.attach_money_rounded,
            color: cat.color,
          ),
          const SizedBox(height: 12),

          // Note field
          _buildTextField(
            controller: _noteController,
            label: 'Note (Optional)',
            hint: 'e.g. Groceries (Tesco)',
            keyboardType: TextInputType.text,
            prefixIcon: Icons.edit_note_rounded,
            color: cat.color,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: cat.color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Log Expense',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mathRow(String label, String value, Color valueColor,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required IconData prefixIcon,
    required Color color,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(prefixIcon, color: color, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle:
              TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
