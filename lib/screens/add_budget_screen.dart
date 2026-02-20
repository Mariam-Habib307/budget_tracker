import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/budget_cubit.dart';
import '../utils/app_theme.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _titleController = TextEditingController();
  final _limitController = TextEditingController();
  IconData _selectedIcon = Icons.category_rounded;
  Color _selectedColor = AppTheme.teal;

  final List<Map<String, dynamic>> _iconOptions = [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.restaurant_rounded, 'label': 'Food'},
    {'icon': Icons.directions_car_rounded, 'label': 'Car'},
    {'icon': Icons.local_hospital_rounded, 'label': 'Health'},
    {'icon': Icons.school_rounded, 'label': 'Education'},
    {'icon': Icons.shopping_bag_rounded, 'label': 'Shopping'},
    {'icon': Icons.flight_rounded, 'label': 'Travel'},
    {'icon': Icons.sports_esports_rounded, 'label': 'Entertainment'},
    {'icon': Icons.fitness_center_rounded, 'label': 'Gym'},
    {'icon': Icons.receipt_long_rounded, 'label': 'Bills'},
    {'icon': Icons.pets_rounded, 'label': 'Pets'},
    {'icon': Icons.category_rounded, 'label': 'Other'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final limit = double.tryParse(_limitController.text);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }
    if (limit == null || limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget limit')),
      );
      return;
    }

    context.read<BudgetCubit>().addCustomBudget(
          title,
          limit,
          _selectedIcon,
          _selectedColor,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('New Category'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _selectedColor.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_selectedIcon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.isEmpty
                            ? 'Category Name'
                            : _titleController.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _titleController.text.isEmpty
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        _limitController.text.isEmpty
                            ? 'Set your limit'
                            : '£${_limitController.text}/month',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Category Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'e.g. Entertainment, Gym...',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Monthly Budget Limit (£)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _limitController,
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Icon'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _iconOptions.length,
              itemBuilder: (context, index) {
                final item = _iconOptions[index];
                final icon = item['icon'] as IconData;
                final selected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? _selectedColor.withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? _selectedColor
                            : Colors.grey.shade200,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: selected ? _selectedColor : AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            _sectionLabel('Color'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppTheme.categoryColors.map((color) {
                final selected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : [],
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
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
