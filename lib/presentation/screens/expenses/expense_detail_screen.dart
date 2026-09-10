import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/expense.dart';
import '../../providers/expense_provider.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String tripId;
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.tripId,
    required this.expenseId,
  });

  Future<void> _deleteExpense(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: const Text(
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(
          expenseControllerProvider.notifier,
        )
        .deleteExpense(
          tripId: tripId,
          expenseId: expenseId,
        );

    final state = ref.read(
      expenseControllerProvider,
    );

    if (!context.mounted) {
      return;
    }

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete expense: ${state.error}',
          ),
        ),
      );

      return;
    }

    ref.invalidate(
      expensesProvider(tripId),
    );

    context.pop();
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final expenseAsync = ref.watch(
      expenseByIdProvider(
        (
          tripId: tripId,
          expenseId: expenseId,
        ),
      ),
    );

    final controllerState = ref.watch(
      expenseControllerProvider,
    );

    return expenseAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Expense Details',
          ),
        ),
        body: Center(
          child: Text(
            'Failed to load expense: $error',
          ),
        ),
      ),

      data: (expense) {
        if (expense == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Expense Details',
              ),
            ),
            body: const Center(
              child: Text(
                'Expense not found',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Expense Details',
            ),
            actions: [
              IconButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () {
                        context.push(
                          '/trips/$tripId/expenses/$expenseId/edit',
                          extra: expense,
                        );
                      },
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),
              IconButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () {
                        _deleteExpense(
                          context,
                          ref,
                        );
                      },
                icon: const Icon(
                  Icons.delete_outline,
                ),
              ),
            ],
          ),

          body: controllerState.isLoading
              ? Stack(
                  children: [
                    _ExpenseContent(
                      expense: expense,
                    ),
                    Container(
                      color: Colors.black12,
                      child: const Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                  ],
                )
              : _ExpenseContent(
                  expense: expense,
                ),
        );
      },
    );
  }
}

class _ExpenseContent extends StatelessWidget {
  final Expense expense;

  const _ExpenseContent({
    required this.expense,
  });

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _InfoCard(
            title: 'Category',
            value: expense.category,
            icon: Icons.category_outlined,
          ),

          const SizedBox(height: 12),

          _InfoCard(
            title: 'Date',
            value:
                _formatDate(expense.date),
            icon:
                Icons.calendar_today_outlined,
          ),

          const SizedBox(height: 12),

          _InfoCard(
            title: 'Split',
            value:
                '${expense.splitBetween.length} person(s)',
            icon: Icons.group_outlined,
          ),

          const SizedBox(height: 12),

          _InfoCard(
            title: 'Per person',
            value:
                '\$${expense.amountPerPerson.toStringAsFixed(2)}',
            icon: Icons.person_outline,
          ),

          if (expense.note != null &&
              expense.note!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 12),

            _InfoCard(
              title: 'Note',
              value: expense.note!,
              icon: Icons.notes_outlined,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}