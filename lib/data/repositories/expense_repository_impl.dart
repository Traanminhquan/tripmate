import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl
    implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<String> createExpense(
    Expense expense,
  ) {
    final model = ExpenseModel(
      id: expense.id,
      tripId: expense.tripId,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      paidBy: expense.paidBy,
      date: expense.date,
      splitBetween: expense.splitBetween,
      note: expense.note,
      createdAt: expense.createdAt,
    );

    return remoteDataSource.createExpense(model);
  }

  @override
  Future<List<Expense>> getExpenses(
    String tripId,
  ) {
    return remoteDataSource.getExpenses(
      tripId,
    );
  }

  @override
  Future<void> updateExpense(
    Expense expense,
  ) {
    final model = ExpenseModel(
      id: expense.id,
      tripId: expense.tripId,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      paidBy: expense.paidBy,
      date: expense.date,
      splitBetween: expense.splitBetween,
      note: expense.note,
      createdAt: expense.createdAt,
    );

    return remoteDataSource.updateExpense(
      model,
    );
  }

  @override
  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  }) {
    return remoteDataSource.deleteExpense(
      tripId: tripId,
      expenseId: expenseId,
    );
  }
}