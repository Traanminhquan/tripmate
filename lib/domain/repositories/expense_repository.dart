import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<String> createExpense(
    Expense expense,
  );

  Future<List<Expense>> getExpenses(
    String tripId,
  );

  Future<void> updateExpense(
    Expense expense,
  );

  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  });
}