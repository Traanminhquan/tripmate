import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/domain/entities/expense.dart';
import 'package:tripmate/domain/usecases/expense_balance_service.dart';

void main() {
  late ExpenseBalanceService service;

  setUp(() {
    service = ExpenseBalanceService();
  });

  test(
    'should calculate equal split correctly',
    () {
      final expenses = [
        Expense(
          id: 'e1',
          tripId: 'trip1',
          title: 'Dinner',
          amount: 90,
          category: 'Food',
          paidBy: 'A',
          date: DateTime(2026, 9, 22),
          splitBetween: const [
            'A',
            'B',
            'C',
          ],
        ),
      ];

      final result = service.calculate(
        expenses: expenses,
        memberIds: const [
          'A',
          'B',
          'C',
        ],
      );

      expect(
        result.balances['A'],
        60,
      );

      expect(
        result.balances['B'],
        -30,
      );

      expect(
        result.balances['C'],
        -30,
      );

      expect(
        result.settlements.length,
        2,
      );
    },
  );

  test(
    'payer does not need to be in split between',
    () {
      final expenses = [
        Expense(
          id: 'e1',
          tripId: 'trip1',
          title: 'Taxi',
          amount: 60,
          category: 'Transport',
          paidBy: 'A',
          date: DateTime(2026, 9, 22),
          splitBetween: const [
            'B',
            'C',
          ],
        ),
      ];

      final result = service.calculate(
        expenses: expenses,
        memberIds: const [
          'A',
          'B',
          'C',
        ],
      );

      expect(
        result.balances['A'],
        60,
      );

      expect(
        result.balances['B'],
        -30,
      );

      expect(
        result.balances['C'],
        -30,
      );
    },
  );
}