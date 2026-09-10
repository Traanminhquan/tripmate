import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense_model.dart';

class ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  ExpenseRemoteDataSource({
    required this.firestore,
  });

  Future<String> createExpense(
    ExpenseModel expense,
  ) async {
    final document = firestore
        .collection('trips')
        .doc(expense.tripId)
        .collection('expenses')
        .doc();

    final data = expense.toMap();

    data['createdAt'] =
        FieldValue.serverTimestamp();

    await document.set(data);

    return document.id;
  }

  Future<List<ExpenseModel>> getExpenses(
    String tripId,
  ) async {
    final snapshot = await firestore
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return ExpenseModel.fromMap(
        id: doc.id,
        tripId: tripId,
        map: doc.data(),
      );
    }).toList();
  }

  Future<void> updateExpense(
    ExpenseModel expense,
  ) async {
    await firestore
        .collection('trips')
        .doc(expense.tripId)
        .collection('expenses')
        .doc(expense.id)
        .update(
          expense.toMap(),
        );
  }

  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  }) async {
    await firestore
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}