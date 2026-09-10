import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/trip_provider.dart';

class EditExpenseScreen
    extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpenseScreen({
    super.key,
    required this.expense,
  });

  @override
  ConsumerState<EditExpenseScreen>
      createState() =>
          _EditExpenseScreenState();
}

class _EditExpenseScreenState
    extends ConsumerState<EditExpenseScreen> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _titleController;

  late final TextEditingController
      _amountController;

  late final TextEditingController
      _noteController;

  late String _selectedCategory;
  late DateTime _selectedDate;

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
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(
      text: widget.expense.title,
    );

    _amountController =
        TextEditingController(
      text: widget.expense.amount
          .toStringAsFixed(2),
    );

    _noteController =
        TextEditingController(
      text: widget.expense.note ?? '',
    );

    _selectedCategory =
        widget.expense.category;

    if (!_categories.contains(
      _selectedCategory,
    )) {
      _categories.add(
        _selectedCategory,
      );
    }

    _selectedDate =
        widget.expense.date;
  }

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
    final result =
        await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      return;
    }

    await ref
        .read(
          expenseControllerProvider.notifier,
        )
        .updateExpense(
          expense: widget.expense,
          title:
              _titleController.text.trim(),
          amount: amount,
          category:
              _selectedCategory,
          date: _selectedDate,
          splitBetween:
              widget.expense.splitBetween,
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
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update expense: ${state.error}',
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
    final controllerState =
        ref.watch(
      expenseControllerProvider,
    );

    final tripAsync = ref.watch(
      tripByIdProvider(
        widget.expense.tripId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Expense',
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
                  children: [
                    TextFormField(
                      controller:
                          _titleController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Expense title',
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
                        prefixIcon: Icon(
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
                      height: 16,
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
                          controllerState
                                  .isLoading
                              ? null
                              : _save,
                      child:
                          controllerState
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
                                  'Save Changes',
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