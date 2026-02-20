class Transaction {
  final String id;
  final String categoryId;
  final double amount;
  final String note;
  final DateTime date;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.note = '',
    required this.date,
  });

  Transaction copyWith({
    String? id,
    String? categoryId,
    double? amount,
    String? note,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        categoryId: json['categoryId'],
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] ?? '',
        date: DateTime.parse(json['date']),
      );
}
