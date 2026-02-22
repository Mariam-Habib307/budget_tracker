import 'package:flutter/material.dart';

class BudgetCategory {
  final String id;
  final String title;
  final int iconCodePoint;
  final String iconFontFamily;
  final double monthlyLimit;
  final double spentAmount;
  final Color color;

  BudgetCategory({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    required this.monthlyLimit,
    this.spentAmount = 0.0,
    required this.color,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);

  double get remainingAmount => monthlyLimit - spentAmount;
  double get percentUsed => monthlyLimit > 0
      ? (spentAmount / monthlyLimit).clamp(0.0, 1.1)
      : 0.0;
  bool get isOverBudget => spentAmount > monthlyLimit;

  BudgetCategory copyWith({
    String? id,
    String? title,
    int? iconCodePoint,
    String? iconFontFamily,
    double? monthlyLimit,
    double? spentAmount,
    Color? color,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      spentAmount: spentAmount ?? this.spentAmount,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        'monthlyLimit': monthlyLimit,
        'spentAmount': spentAmount,
        'color': color.value,
      };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'] as String,
        title: json['title'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        iconFontFamily:
            (json['iconFontFamily'] as String?) ?? 'MaterialIcons',
        monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
        spentAmount: (json['spentAmount'] as num).toDouble(),
        color: Color(json['color'] as int),
      );
}