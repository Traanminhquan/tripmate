import '../entities/expense.dart';
import '../entities/settlement.dart';

class ExpenseBalanceResult {
  final Map<String, double> balances;
  final List<Settlement> settlements;

  const ExpenseBalanceResult({
    required this.balances,
    required this.settlements,
  });
}

class ExpenseBalanceService {
  ExpenseBalanceResult calculate({
    required List<Expense> expenses,
    required List<String> memberIds,
  }) {
    final balances = <String, double>{
      for (final id in memberIds) id: 0,
    };

    for (final expense in expenses) {
      if (expense.splitBetween.isEmpty) {
        continue;
      }

      balances.putIfAbsent(
        expense.paidBy,
        () => 0,
      );

      balances[expense.paidBy] =
          balances[expense.paidBy]! +
              expense.amount;

      final share =
          expense.amount /
              expense.splitBetween.length;

      for (final memberId
          in expense.splitBetween) {
        balances.putIfAbsent(
          memberId,
          () => 0,
        );

        balances[memberId] =
            balances[memberId]! - share;
      }
    }

    // Tránh các sai số kiểu 1.776e-15.
    final normalizedBalances =
        balances.map(
      (id, value) => MapEntry(
        id,
        _roundMoney(value),
      ),
    );

    final settlements =
        _buildSettlements(
      normalizedBalances,
    );

    return ExpenseBalanceResult(
      balances: normalizedBalances,
      settlements: settlements,
    );
  }

  List<Settlement> _buildSettlements(
    Map<String, double> balances,
  ) {
    final creditors =
        <_BalanceEntry>[];

    final debtors =
        <_BalanceEntry>[];

    balances.forEach(
      (userId, balance) {
        if (balance > 0.009) {
          creditors.add(
            _BalanceEntry(
              userId: userId,
              amount: balance,
            ),
          );
        } else if (balance < -0.009) {
          debtors.add(
            _BalanceEntry(
              userId: userId,
              amount: -balance,
            ),
          );
        }
      },
    );

    creditors.sort(
      (a, b) =>
          b.amount.compareTo(a.amount),
    );

    debtors.sort(
      (a, b) =>
          b.amount.compareTo(a.amount),
    );

    final settlements =
        <Settlement>[];

    var debtorIndex = 0;
    var creditorIndex = 0;

    while (debtorIndex <
            debtors.length &&
        creditorIndex <
            creditors.length) {
      final debtor =
          debtors[debtorIndex];

      final creditor =
          creditors[creditorIndex];

      final amount =
          debtor.amount < creditor.amount
              ? debtor.amount
              : creditor.amount;

      final roundedAmount =
          _roundMoney(amount);

      if (roundedAmount > 0) {
        settlements.add(
          Settlement(
            fromUserId:
                debtor.userId,
            toUserId:
                creditor.userId,
            amount:
                roundedAmount,
          ),
        );
      }

      debtor.amount = _roundMoney(
        debtor.amount - amount,
      );

      creditor.amount = _roundMoney(
        creditor.amount - amount,
      );

      if (debtor.amount <= 0.009) {
        debtorIndex++;
      }

      if (creditor.amount <= 0.009) {
        creditorIndex++;
      }
    }

    return settlements;
  }

  double _roundMoney(
    double value,
  ) {
    return (value * 100).round() /
        100;
  }
}

class _BalanceEntry {
  final String userId;
  double amount;

  _BalanceEntry({
    required this.userId,
    required this.amount,
  });
}