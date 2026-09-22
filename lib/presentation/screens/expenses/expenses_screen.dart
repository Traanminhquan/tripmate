import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/expense_provider.dart';
import '../../providers/trip_provider.dart';
import '../../../domain/entities/settlement.dart';
import '../../providers/user_provider.dart';

class ExpensesScreen extends ConsumerWidget {
  final String tripId;

  const ExpensesScreen({
    super.key,
    required this.tripId,
  });

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(
          2,
          '0',
        );

    final month =
        date.month.toString().padLeft(
          2,
          '0',
        );

    return '$day/$month/${date.year}';
  }

  IconData _categoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;

      case 'Accommodation':
        return Icons.hotel;

      case 'Transport':
        return Icons.directions_car;

      case 'Tickets':
        return Icons.confirmation_number;

      case 'Shopping':
        return Icons.shopping_bag;

      case 'Entertainment':
        return Icons.movie;

      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final tripAsync = ref.watch(
      tripByIdProvider(tripId),
    );

    final expensesAsync = ref.watch(
      expensesProvider(tripId),
    );

    final balanceAsync = ref.watch(
      expenseBalanceProvider(tripId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/trips/$tripId/expenses/create',
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Expense'),
      ),

      body: tripAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stackTrace) => Center(
          child: Text(
            'Failed to load trip: $error',
          ),
        ),

        data: (trip) {
          if (trip == null) {
            return const Center(
              child: Text('Trip not found'),
            );
          }

          return expensesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),

            error: (error, stackTrace) => Center(
              child: Text(
                'Failed to load expenses: $error',
              ),
            ),

            data: (expenses) {
              final total = expenses.fold<double>(
                0,
                (sum, expense) =>
                    sum + expense.amount,
              );

              final Map<String, double> categoryTotals = {};

              for (final expense in expenses) {
                categoryTotals.update(
                  expense.category,
                  (value) => value + expense.amount,
                  ifAbsent: () => expense.amount,
                );
              }

              String? topCategory;
              double topCategoryAmount = 0;

              categoryTotals.forEach((category, amount) {
                if (amount > topCategoryAmount) {
                  topCategory = category;
                  topCategoryAmount = amount;
                }
              });

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    trip.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total spent',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Transactions',
                          value: expenses.length.toString(),
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Top category',
                          value: topCategory ?? '-',
                          icon: Icons.pie_chart_outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Spending by Category',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Group Balance',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),

                  const SizedBox(height: 14),

                  balanceAsync.when(
                    loading: () =>
                        const Center(
                      child:
                          CircularProgressIndicator(),
                    ),

                    error: (
                      error,
                      stackTrace,
                    ) =>
                        Text(
                      'Failed to calculate balance: $error',
                    ),

                    data: (result) {
                      if (result.settlements.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border,
                            ),
                          ),
                          child: const Text(
                            'Everyone is settled up.',
                          ),
                        );
                      }

                      return Column(
                        children:
                            result.settlements
                                .map(
                                  (settlement) =>
                                      _SettlementCard(
                                    settlement:
                                        settlement,
                                  ),
                                )
                                .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  if (categoryTotals.isEmpty)
                    const Text(
                      'No spending data yet.',
                    )
                  else
                    ...(
                      categoryTotals.entries.toList()
                      ..sort(
                        (a, b) => b.value.compareTo(a.value),
                      )
                      ).map(
                      (entry) {
                        final percentage = total == 0
                            ? 0.0
                            : entry.value / total;

                        return _CategoryProgress(
                          category: entry.key,
                          amount: entry.value,
                          percentage: percentage,
                        );
                      },
                    ),

                  const SizedBox(height: 28),

                  const SizedBox(height: 24),

                  Text(
                    'Expenses',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),

                  const SizedBox(height: 12),

                  if (expenses.isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 40,
                      ),
                      child: Center(
                        child: Text(
                          'No expenses yet.',
                        ),
                      ),
                    )
                  else
                    ...expenses.map(
                      (expense) {
                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: ListTile(
                            onTap: () {
                              context.push(
                                '/trips/$tripId/expenses/${expense.id}',
                              );
                            },
                            leading: CircleAvatar(
                              child: Icon(
                                _categoryIcon(
                                  expense.category,
                                ),
                              ),
                            ),
                            title: Text(
                              expense.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${expense.category} • ${_formatDate(expense.date)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.chevron_right,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CategoryProgress extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;

  const _CategoryProgress({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _categoryIcon(category),
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            borderRadius:
                BorderRadius.circular(20),
          ),

          const SizedBox(height: 6),

          Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;

      case 'Accommodation':
        return Icons.hotel;

      case 'Transport':
        return Icons.directions_car;

      case 'Tickets':
        return Icons.confirmation_number;

      case 'Shopping':
        return Icons.shopping_bag;

      case 'Entertainment':
        return Icons.movie;

      default:
        return Icons.receipt_long;
    }
  }
}

class _SettlementCard
    extends ConsumerWidget {
  final Settlement settlement;

  const _SettlementCard({
    required this.settlement,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final fromAsync = ref.watch(
      userByIdProvider(
        settlement.fromUserId,
      ),
    );

    final toAsync = ref.watch(
      userByIdProvider(
        settlement.toUserId,
      ),
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(16),
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
          const CircleAvatar(
            child: Icon(
              Icons.swap_horiz,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: fromAsync.when(
              loading: () =>
                  const Text(
                'Loading...',
              ),

              error: (
                error,
                stackTrace,
              ) =>
                  const Text(
                'Unknown user',
              ),

              data: (fromUser) {
                return toAsync.when(
                  loading: () =>
                      const Text(
                    'Loading...',
                  ),

                  error: (
                    error,
                    stackTrace,
                  ) =>
                      const Text(
                    'Unknown user',
                  ),

                  data: (toUser) {
                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                fromUser?.name ??
                                    'Unknown',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const TextSpan(
                            text: ' owes ',
                          ),
                          TextSpan(
                            text:
                                toUser?.name ??
                                    'Unknown',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Text(
            '\$${settlement.amount.toStringAsFixed(2)}',
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}