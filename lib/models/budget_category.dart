import 'package:flutter/material.dart';

class BudgetCategory {
  final String id;
  final String title;
  final String iconKey;       // e.g. "home", "food", "car" — resolved at UI layer
  final double monthlyLimit;
  final double spentAmount;
  final Color color;

  BudgetCategory({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.monthlyLimit,
    this.spentAmount = 0.0,
    required this.color,
  });

  double get remainingAmount => monthlyLimit - spentAmount;
  double get percentUsed =>
      monthlyLimit > 0 ? (spentAmount / monthlyLimit).clamp(0.0, 1.1) : 0.0;
  bool get isOverBudget => spentAmount > monthlyLimit;

  BudgetCategory copyWith({
    String? id,
    String? title,
    String? iconKey,
    double? monthlyLimit,
    double? spentAmount,
    Color? color,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      iconKey: iconKey ?? this.iconKey,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      spentAmount: spentAmount ?? this.spentAmount,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'monthlyLimit': monthlyLimit,
        'spentAmount': spentAmount,
        'color': color.value,
      };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'] as String,
        title: json['title'] as String,
        iconKey: (json['iconKey'] as String?) ??
            // backwards-compat: old saves used iconCodePoint, default to 'other'
            'other',
        monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
        spentAmount: (json['spentAmount'] as num).toDouble(),
        color: Color(json['color'] as int),
      );
}