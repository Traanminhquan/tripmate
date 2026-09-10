import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/trip_provider.dart';

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

  DateTime _selectedDate =
      DateTime.now();

  String _selectedCategory = 'Food';

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
    DateTime initialDate =
        _selectedDate;

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

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount.',
          ),
        ),
      );

      return;
    }

    final firebaseUser = ref
        .read(firebaseAuthProvider)
        .currentUser;

    if (firebaseUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'User is not logged in.',
          ),
        ),
      );

      return;
    }

    await ref
        .read(
          expenseControllerProvider.notifier,
        )
        .createExpense(
          tripId: widget.tripId,
          title:
              _titleController.text.trim(),
          amount: amount,
          category:
              _selectedCategory,
          date: _selectedDate,

          // Hiện tại trip mới chỉ có owner.
          // Group splitting sẽ mở rộng sau.
          splitBetween: [
            firebaseUser.uid,
          ],

          note:
              _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
        );

    final state =
        ref.read(
      expenseControllerProvider,
    );

    if (!mounted) {
      return;
    }

    if (state.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create expense: ${state.error}',
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
    final expenseState = ref.watch(
      expenseControllerProvider,
    );

    final tripAsync = ref.watch(
      tripByIdProvider(widget.tripId),
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
                            'Hotel',
                        prefixIcon: Icon(
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
                        prefixIcon: Icon(
                          Icons
                              .attach_money,
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
                          return 'Please enter amount';
                        }

                        final amount =
                            double
                                .tryParse(
                          value.trim(),
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
                        prefixIcon: Icon(
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
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
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
                          _formatDate(
                            _selectedDate,
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
                        hintText:
                            '2 nights...',
                        alignLabelWithHint:
                            true,
                        prefixIcon: Icon(
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
                                    color: Colors
                                        .white,
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
      ),
    );
  }
}