import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/monthly_container.dart';
import '../utils/app_theme.dart';

class MonthPickerStrip extends StatefulWidget {
  final String currentMonthKey;
  final List<String> availableKeys;
  final ValueChanged<DateTime> onMonthSelected;

  const MonthPickerStrip({
    super.key,
    required this.currentMonthKey,
    required this.availableKeys,
    required this.onMonthSelected,
  });

  @override
  State<MonthPickerStrip> createState() => _MonthPickerStripState();
}

class _MonthPickerStripState extends State<MonthPickerStrip> {
  late ScrollController _scroll;

  // We show a window of months: ±12 around current month
  late List<DateTime> _months;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _buildMonths();
    _scroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  @override
  void didUpdateWidget(MonthPickerStrip old) {
    super.didUpdateWidget(old);
    if (old.currentMonthKey != widget.currentMonthKey) {
      _buildMonths();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrent());
    }
  }

  void _buildMonths() {
    final now = DateTime.now();
    final current = MonthlyContainer.dateFor(widget.currentMonthKey);
    _months = List.generate(25, (i) {
      final d = DateTime(now.year, now.month - 12 + i);
      return DateTime(d.year, d.month);
    });
    _currentIndex =
        _months.indexWhere((m) => MonthlyContainer.keyFor(m) == widget.currentMonthKey);
    if (_currentIndex < 0) _currentIndex = 12;
  }

  void _scrollToCurrent() {
    if (!_scroll.hasClients) return;
    const itemWidth = 72.0;
    final target = (_currentIndex * itemWidth) -
        MediaQuery.of(context).size.width / 2 +
        itemWidth / 2;
    _scroll.animateTo(
      target.clamp(0.0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final month = _months[index];
          final key = MonthlyContainer.keyFor(month);
          final isSelected = key == widget.currentMonthKey;
          final hasData = widget.availableKeys.contains(key);
          final isToday = MonthlyContainer.keyFor(DateTime.now()) == key;

          return GestureDetector(
            onTap: () => widget.onMonthSelected(month),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 64,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.teal
                    : hasData
                        ? AppTheme.teal.withOpacity(0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.teal
                      : isToday
                          ? AppTheme.teal.withOpacity(0.4)
                          : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(month),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : hasData
                              ? AppTheme.teal
                              : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    month.year.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppTheme.textSecondary,
                    ),
                  ),
                  if (hasData && !isSelected) ...[
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}