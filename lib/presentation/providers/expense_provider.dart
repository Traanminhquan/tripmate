import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import 'user_provider.dart';
//import '../../domain/entities/settlement.dart';
import '../../domain/usecases/expense_balance_service.dart';
import 'trip_provider.dart';

final expenseRemoteDataSourceProvider =
    Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSource(
    firestore: ref.read(firestoreProvider),
  );
});

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    remoteDataSource:
        ref.read(expenseRemoteDataSourceProvider),
  );
});

final expensesProvider =
    FutureProvider.family<
        List<Expense>,
        String>(
  (ref, tripId) {
    return ref
        .read(expenseRepositoryProvider)
        .getExpenses(tripId);
  },
);

class ExpenseController
    extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createExpense({
    required String tripId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime date,
    required List<String> splitBetween,
    String? note,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      if (splitBetween.isEmpty) {
        throw Exception(
          'Select at least one member to split this expense.',
        );
      }

      final expense = Expense(
        id: '',
        tripId: tripId,
        title: title,
        amount: amount,
        category: category,
        paidBy: paidBy,
        date: date,
        splitBetween: splitBetween,
        note: note,
      );

      await ref
          .read(expenseRepositoryProvider)
          .createExpense(expense);

      ref.invalidate(
        expensesProvider(tripId),
      );

      ref.invalidate(
        expenseBalanceProvider(tripId),
      );
    });
  }

  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(expenseRepositoryProvider)
          .deleteExpense(
            tripId: tripId,
            expenseId: expenseId,
          );

      ref.invalidate(
        expensesProvider(tripId),
      );

      ref.invalidate(
        expenseBalanceProvider(tripId),
      );
    });
  }

  Future<void> updateExpense({
    required Expense expense,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime date,
    required List<String> splitBetween,
    String? note,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      if (splitBetween.isEmpty) {
        throw Exception(
          'Select at least one member to split this expense.',
        );
      }

      final updatedExpense = Expense(
        id: expense.id,
        tripId: expense.tripId,
        title: title,
        amount: amount,
        category: category,
        paidBy: paidBy,
        date: date,
        splitBetween: splitBetween,
        note: note,
        createdAt: expense.createdAt,
      );

      await ref
          .read(expenseRepositoryProvider)
          .updateExpense(
            updatedExpense,
          );

      ref.invalidate(
        expensesProvider(
          expense.tripId,
        ),
      );

      ref.invalidate(
        expenseByIdProvider(
          (
            tripId: expense.tripId,
            expenseId: expense.id,
          ),
        ),
      );

      ref.invalidate(
        expenseBalanceProvider(
          expense.tripId,
        ),
      );
    });
  }
}

final expenseControllerProvider =
    AsyncNotifierProvider<
        ExpenseController,
        void>(
  ExpenseController.new,
);

final expenseByIdProvider =
    FutureProvider.family<
        Expense?,
        ({String tripId, String expenseId})>(
  (ref, params) async {
    final expenses = await ref
        .read(expenseRepositoryProvider)
        .getExpenses(params.tripId);

    for (final expense in expenses) {
      if (expense.id == params.expenseId) {
        return expense;
      }
    }

    return null;
  },
);

final expenseBalanceServiceProvider =
    Provider<ExpenseBalanceService>((ref) {
  return ExpenseBalanceService();
});

final expenseBalanceProvider =
    FutureProvider.family<
        ExpenseBalanceResult,
        String>(
  (ref, tripId) async {
    final trip =
        await ref.watch(
      tripByIdProvider(tripId).future,
    );

    if (trip == null) {
      throw Exception(
        'Trip not found',
      );
    }

    final expenses =
        await ref.watch(
      expensesProvider(tripId).future,
    );

    return ref
        .read(
          expenseBalanceServiceProvider,
        )
        .calculate(
          expenses: expenses,
          memberIds:
              trip.memberIds,
        );
  },
);