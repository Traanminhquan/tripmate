import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.amount,
    required super.category,
    required super.paidBy,
    required super.date,
    required super.splitBetween,
    super.note,
    super.createdAt,
  });

  factory ExpenseModel.fromMap({
    required String id,
    required String tripId,
    required Map<String, dynamic> map,
  }) {
    return ExpenseModel(
      id: id,
      tripId: tripId,
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: map['category'] ?? '',
      paidBy: map['paidBy'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      splitBetween:
          List<String>.from(map['splitBetween'] ?? []),
      note: map['note'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'paidBy': paidBy,
      'date': Timestamp.fromDate(date),
      'splitBetween': splitBetween,
      'note': note,
    };
  }
}