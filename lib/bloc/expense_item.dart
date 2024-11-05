import 'package:equatable/equatable.dart';

final List<String> categories = [
  'Food',
  'Transport',
  'Clothes',
  'Utilities',
  'Others'
];

class ExpenseItem extends Equatable {
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String id;

  const ExpenseItem({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'title': title,
      'amount': amount,
      'category': category,
      'id': id,
    };
  }

  @override
  List<Object> get props => [title, amount, category, date, id];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'id': id,
    };
  }

  ExpenseItem copyWith(
      {String? title,
      double? amount,
      String? category,
      DateTime? date,
      String? id}) {
    return ExpenseItem(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      id: id ?? this.id,
    );
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      title: json['title'],
      amount: json['amount'],
      category: json['category'],
      date: DateTime.parse(
        json['date'],
      ),
      id: json['id'],
    );
  }
}
