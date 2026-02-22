import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

/// Tap to edit income inline.  Shows real-time allocation status.
class IncomeHeader extends StatefulWidget {
  final double income;
  final double totalBudgeted;
  final double totalSpent;
  final ValueChanged<double> onIncomeChanged;

  const IncomeHeader({
    super.key,
    required this.income,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.onIncomeChanged,
  });

  @override
  State<IncomeHeader> createState() => _IncomeHeaderState();
}

class _IncomeHeaderState extends State<IncomeHeader> {
  bool _editing = false;
  late TextEditingController _ctrl;

  double get _unallocated => widget.income - widget.totalBudgeted;
  double get _remainingCash => widget.income - widget.totalSpent;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.income > 0 ? widget.income.toStringAsFixed(0) : '');
  }

  @override
  void didUpdateWidget(IncomeHeader old) {
    super.didUpdateWidget(old);
    if (!_editing && old.income != widget.income) {
      _ctrl.text =
          widget.income > 0 ? widget.income.toStringAsFixed(0) : '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit() {
    final val = double.tryParse(_ctrl.text) ?? 0;
    widget.onIncomeChanged(val);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Income row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: AppTheme.teal, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                "This Month's Income",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _editing = !_editing),
                child: Icon(
                  _editing ? Icons.check_rounded : Icons.edit_rounded,
                  size: 18,
                  color: AppTheme.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Editable income value
          _editing
              ? Row(
                  children: [
                    const Text('£ ',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.teal,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _commit(),
                      ),
                    ),
                    TextButton(
                      onPressed: _commit,
                      child: const Text('Save'),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => setState(() => _editing = true),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.income > 0
                            ? '£${widget.income.toStringAsFixed(0)}'
                            : 'Tap to set income',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: widget.income > 0
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      if (widget.income > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            '/ month',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

          if (widget.income > 0) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Budget allocation breakdown
            _allocationRow(
              label: 'Budgeted',
              value: widget.totalBudgeted,
              total: widget.income,
              color: AppTheme.teal,
            ),
            const SizedBox(height: 6),
            _allocationRow(
              label: 'Spent',
              value: widget.totalSpent,
              total: widget.income,
              color: AppTheme.coral,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _pill(
                  'Unallocated',
                  '£${_unallocated.toStringAsFixed(0)}',
                  _unallocated < 0 ? AppTheme.danger : AppTheme.success,
                ),
                _pill(
                  'Cash Remaining',
                  '£${_remainingCash.toStringAsFixed(0)}',
                  _remainingCash < 0 ? AppTheme.danger : AppTheme.teal,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _allocationRow({
    required String label,
    required double value,
    required double total,
    required Color color,
  }) {
    final pct = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
            Text('£${value.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(0)}%)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _pill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    );
  }
}