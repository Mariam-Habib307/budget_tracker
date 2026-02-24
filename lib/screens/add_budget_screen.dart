import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/budget_cubit.dart';
import '../utils/app_theme.dart';
import '../utils/icon_registry.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _titleCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();

  // ✅ Store key strings — never IconData objects
  String _iconKey = 'other';
  Color _color = AppTheme.teal;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final limit = double.tryParse(_limitCtrl.text);
    if (title.isEmpty) { _snack('Please enter a category name'); return; }
    if (limit == null || limit <= 0) { _snack('Please enter a valid budget limit'); return; }
    context.read<BudgetCubit>().addCustomBudget(title, limit, _iconKey, _color);
    Navigator.pop(context);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final resolvedIcon = IconRegistry.resolve(_iconKey);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(title: const Text('New Category')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live preview card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _color.withOpacity(0.25), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(resolvedIcon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleCtrl.text.isEmpty ? 'Category Name' : _titleCtrl.text,
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: _titleCtrl.text.isEmpty
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        _limitCtrl.text.isEmpty
                            ? 'Set your limit'
                            : '£${_limitCtrl.text}/month',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _label('Category Name'),
            const SizedBox(height: 8),
            _textField(ctrl: _titleCtrl, hint: 'e.g. Entertainment…',
                onChange: (_) => setState(() {})),
            const SizedBox(height: 18),

            _label('Monthly Limit (£)'),
            const SizedBox(height: 8),
            _textField(
              ctrl: _limitCtrl, hint: '0.00',
              type: const TextInputType.numberWithOptions(decimal: true),
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChange: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),

            _label('Icon'),
            const SizedBox(height: 10),
            // ✅ Iterate over IconRegistry — all values are constants
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemCount: IconRegistry.all.length,
              itemBuilder: (_, i) {
                final entry = IconRegistry.all[i];
                final selected = entry.key == _iconKey;
                return GestureDetector(
                  onTap: () => setState(() => _iconKey = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? _color.withOpacity(0.12) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected ? _color : Colors.grey.shade200,
                          width: selected ? 2 : 1),
                    ),
                    child: Icon(entry.value,
                        color: selected ? _color : AppTheme.textSecondary,
                        size: 22),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),

            _label('Color'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: AppTheme.categoryColors.map((c) {
                final sel = c == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 3),
                      boxShadow: sel
                          ? [BoxShadow(
                              color: c.withOpacity(0.5),
                              blurRadius: 8, spreadRadius: 1)]
                          : [],
                    ),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color, foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Create Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary));

  Widget _textField({
    required TextEditingController ctrl,
    required String hint,
    TextInputType? type,
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChange,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: ctrl, keyboardType: type,
        inputFormatters: formatters, onChanged: onChange,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}