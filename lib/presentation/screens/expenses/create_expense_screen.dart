import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/app_user.dart';
import '../../providers/expense_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';

class CreateExpenseScreen
    extends ConsumerStatefulWidget {
  final String tripId;

  const CreateExpenseScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<CreateExpenseScreen> createState() =>
      _CreateExpenseScreenState();
}

class _CreateExpenseScreenState
    extends ConsumerState<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _amountController =
      TextEditingController();

  final _noteController =
      TextEditingController();

  DateTime? _selectedDate;

  String _selectedCategory = 'Food';

  String? _paidBy;

  final Set<String> _splitBetween = {};

  final List<String> _categories = [
    'Food',
    'Accommodation',
    'Transport',
    'Tickets',
    'Shopping',
    'Entertainment',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    var initialDate =
        _selectedDate ?? startDate;

    if (initialDate.isBefore(startDate)) {
      initialDate = startDate;
    }

    if (initialDate.isAfter(endDate)) {
      initialDate = endDate;
    }

    final result =
        await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startDate,
      lastDate: endDate,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _selectedDate = result;
    });
  }

  Future<void> _createExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_paidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select who paid.',
          ),
        ),
      );

      return;
    }

    if (_splitBetween.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one person to split the expense.',
          ),
        ),
      );

      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select expense date.',
          ),
        ),
      );

      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return;
    }

    await ref
        .read(
          expenseControllerProvider.notifier,
        )
        .createExpense(
          tripId: widget.tripId,
          title: _titleController.text.trim(),
          amount: amount,
          category: _selectedCategory,
          paidBy: _paidBy!,
          date: _selectedDate!,
          splitBetween:
              _splitBetween.toList(),
          note:
              _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
        );

    final state = ref.read(
      expenseControllerProvider,
    );

    if (!mounted) {
      return;
    }

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );

      return;
    }

    context.pop();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final tripAsync = ref.watch(
      tripByIdProvider(widget.tripId),
    );

    final expenseState = ref.watch(
      expenseControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
        ),
      ),

      body: tripAsync.when(
        loading: () => const Center(
          child:
              CircularProgressIndicator(),
        ),

        error: (
          error,
          stackTrace,
        ) =>
            Center(
          child: Text(
            'Failed to load trip: $error',
          ),
        ),

        data: (trip) {
          if (trip == null) {
            return const Center(
              child: Text(
                'Trip not found',
              ),
            );
          }

          final membersAsync =
              ref.watch(
            tripMembersProvider(
              trip.memberIds,
            ),
          );

          return membersAsync.when(
            loading: () => const Center(
              child:
                  CircularProgressIndicator(),
            ),

            error: (
              error,
              stackTrace,
            ) =>
                Center(
              child: Text(
                'Failed to load members: $error',
              ),
            ),

            data: (members) {
              if (members.isEmpty) {
                return const Center(
                  child: Text(
                    'No trip members found.',
                  ),
                );
              }

              _initializeDefaults(
                members,
                trip.ownerId,
              );

              return SafeArea(
                child:
                    SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Expense information',
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        TextFormField(
                          controller:
                              _titleController,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Expense title',
                            hintText:
                                'Dinner',
                            prefixIcon:
                                Icon(
                              Icons
                                  .receipt_long_outlined,
                            ),
                          ),
                          validator: (
                            value,
                          ) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Please enter expense title';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        TextFormField(
                          controller:
                              _amountController,

                          onChanged: (value) {
                            setState(() {});
                          },
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .allow(
                              RegExp(
                                r'^\d*\.?\d{0,2}',
                              ),
                            ),
                          ],
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Amount',
                            hintText:
                                '120.00',
                            prefixIcon:
                                Icon(
                              Icons
                                  .attach_money,
                            ),
                          ),
                          validator: (
                            value,
                          ) {
                            final amount =
                                double
                                    .tryParse(
                              value ?? '',
                            );

                            if (amount ==
                                    null ||
                                amount <=
                                    0) {
                              return 'Please enter a valid amount';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        DropdownButtonFormField<
                            String>(
                          initialValue:
                              _selectedCategory,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Category',
                            prefixIcon:
                                Icon(
                              Icons
                                  .category_outlined,
                            ),
                          ),
                          items: _categories
                              .map(
                                (
                                  category,
                                ) =>
                                    DropdownMenuItem<
                                        String>(
                                  value:
                                      category,
                                  child: Text(
                                    category,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (
                            value,
                          ) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(() {
                              _selectedCategory =
                                  value;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        Text(
                          'Paid by',
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        DropdownButtonFormField<
                            String>(
                          initialValue:
                              _paidBy,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Who paid?',
                            prefixIcon:
                                Icon(
                              Icons
                                  .payments_outlined,
                            ),
                          ),
                          items: members
                              .map(
                                (
                                  member,
                                ) =>
                                    DropdownMenuItem<
                                        String>(
                                  value:
                                      member.id,
                                  child: Text(
                                    member.name,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (
                            value,
                          ) {
                            setState(() {
                              _paidBy =
                                  value;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              'Split between',
                              style:
                                  Theme.of(context)
                                      .textTheme
                                      .titleLarge,
                            ),

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_splitBetween
                                          .length ==
                                      members
                                          .length) {
                                    _splitBetween
                                        .clear();
                                  } else {
                                    _splitBetween
                                      ..clear()
                                      ..addAll(
                                        members.map(
                                          (
                                            member,
                                          ) =>
                                              member
                                                  .id,
                                        ),
                                      );
                                  }
                                });
                              },
                              child: Text(
                                _splitBetween
                                            .length ==
                                        members
                                            .length
                                    ? 'Clear all'
                                    : 'Select all',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        ...members.map(
                          (
                            member,
                          ) {
                            return CheckboxListTile(
                              contentPadding:
                                  EdgeInsets
                                      .zero,
                              title: Text(
                                member.name,
                              ),
                              subtitle: Text(
                                member.email,
                              ),
                              value:
                                  _splitBetween
                                      .contains(
                                member.id,
                              ),
                              onChanged: (
                                selected,
                              ) {
                                setState(() {
                                  if (selected ==
                                      true) {
                                    _splitBetween
                                        .add(
                                      member.id,
                                    );
                                  } else {
                                    _splitBetween
                                        .remove(
                                      member.id,
                                    );
                                  }
                                });
                              },
                            );
                          },
                        ),

                        if (_splitBetween
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 8,
                          ),

                          _SplitPreview(
                            amount:
                                double.tryParse(
                                      _amountController
                                          .text,
                                    ) ??
                                    0,
                            people:
                                _splitBetween
                                    .length,
                          ),
                        ],

                        const SizedBox(
                          height: 24,
                        ),

                        Text(
                          'Expense date',
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        InkWell(
                          onTap: () {
                            _selectDate(
                              trip.startDate,
                              trip.endDate,
                            );
                          },
                          child:
                              InputDecorator(
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Date',
                              prefixIcon:
                                  Icon(
                                Icons
                                    .calendar_today_outlined,
                              ),
                            ),
                            child: Text(
                              _selectedDate ==
                                      null
                                  ? 'Select date'
                                  : _formatDate(
                                      _selectedDate!,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        TextFormField(
                          controller:
                              _noteController,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Note (optional)',
                            prefixIcon:
                                Icon(
                              Icons
                                  .notes_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 32,
                        ),

                        ElevatedButton(
                          onPressed:
                              expenseState
                                      .isLoading
                                  ? null
                                  : _createExpense,
                          child:
                              expenseState
                                      .isLoading
                                  ? const SizedBox(
                                      width:
                                          24,
                                      height:
                                          24,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Add Expense',
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _initializeDefaults(
    List<AppUser> members,
    String ownerId,
  ) {
    if (_paidBy != null) {
      return;
    }

    final ownerExists = members.any(
      (member) => member.id == ownerId,
    );

    _paidBy = ownerExists
        ? ownerId
        : members.first.id;

    _splitBetween.addAll(
      members.map(
        (member) => member.id,
      ),
    );

    _selectedDate ??= DateTime.now();
  }
}

class _SplitPreview extends StatelessWidget {
  final double amount;
  final int people;

  const _SplitPreview({
    required this.amount,
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    final perPerson =
        people == 0
            ? 0
            : amount / people;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calculate_outlined,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              '$people people • '
              '\$${perPerson.toStringAsFixed(2)} each',
            ),
          ),
        ],
      ),
    );
  }
}