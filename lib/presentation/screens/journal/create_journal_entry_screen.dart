import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/journal_provider.dart';

class CreateJournalEntryScreen
    extends ConsumerStatefulWidget {
  final String tripId;

  const CreateJournalEntryScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<
      CreateJournalEntryScreen>
      createState() =>
          _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState
    extends ConsumerState<
        CreateJournalEntryScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _contentController =
      TextEditingController();

  DateTime _selectedDate =
      DateTime.now();

  String _selectedMood =
      'Happy';

  final _moods = [
    'Excited',
    'Happy',
    'Relaxed',
    'Tired',
    'Sad',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final result =
        await showDatePicker(
      context: context,
      initialDate:
          _selectedDate,
      firstDate: DateTime(
        2000,
      ),
      lastDate: DateTime(
        2100,
      ),
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

    await ref
        .read(
          journalControllerProvider
              .notifier,
        )
        .createEntry(
          tripId: widget.tripId,
          title:
              _titleController.text
                  .trim(),
          content:
              _contentController.text
                  .trim(),
          date: _selectedDate,
          mood:
              _selectedMood,
        );

    final state =
        ref.read(
      journalControllerProvider,
    );

    if (!mounted) {
      return;
    }

    if (state.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            state.error.toString(),
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
    final state =
        ref.watch(
      journalControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Journal Entry',
        ),
      ),

      body:
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
              TextFormField(
                controller:
                    _titleController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Title',
                  prefixIcon: Icon(
                    Icons
                        .title_outlined,
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
                    return 'Please enter a title';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _contentController,
                maxLines: 8,
                decoration:
                    const InputDecoration(
                  labelText:
                      'What happened today?',
                  alignLabelWithHint:
                      true,
                ),
                validator: (
                  value,
                ) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please write something';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              DropdownButtonFormField<
                  String>(
                initialValue:
                    _selectedMood,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Mood',
                  prefixIcon: Icon(
                    Icons
                        .sentiment_satisfied_alt_outlined,
                  ),
                ),
                items: _moods
                    .map(
                      (mood) =>
                          DropdownMenuItem<
                              String>(
                        value: mood,
                        child:
                            Text(mood),
                      ),
                    )
                    .toList(),
                onChanged: (
                  value,
                ) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedMood =
                        value;
                  });
                },
              ),

              const SizedBox(
                height: 16,
              ),

              InkWell(
                onTap:
                    _selectDate,
                child:
                    InputDecorator(
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Date',
                    prefixIcon: Icon(
                      Icons
                          .calendar_today_outlined,
                    ),
                  ),
                  child: Text(
                    '${_selectedDate.day}/'
                    '${_selectedDate.month}/'
                    '${_selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              ElevatedButton(
                onPressed:
                    state.isLoading
                        ? null
                        : _save,
                child:
                    state.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Entry',
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}