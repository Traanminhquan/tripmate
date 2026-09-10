import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/activity_provider.dart';
import '../../providers/trip_provider.dart';

class CreateActivityScreen extends ConsumerStatefulWidget {
  final String tripId;

  const CreateActivityScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<CreateActivityScreen> createState() =>
      _CreateActivityScreenState();
}

class _CreateActivityScreenState
    extends ConsumerState<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return 'Select time';
    }

    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _selectDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? startDate,
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

  Future<void> _selectTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime:
          _selectedTime ??
          const TimeOfDay(
            hour: 9,
            minute: 0,
          ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _selectedTime = result;
    });
  }

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a date.',
          ),
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a time.',
          ),
        ),
      );
      return;
    }

    final timeString =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime!.minute.toString().padLeft(2, '0')}';

    await ref
        .read(activityControllerProvider.notifier)
        .createActivity(
          tripId: widget.tripId,
          title: _titleController.text.trim(),
          location:
              _locationController.text.trim(),
          date: _selectedDate!,
          startTime: timeString,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    final state =
        ref.read(activityControllerProvider);

    if (!mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create activity: ${state.error}',
          ),
        ),
      );

      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(
      tripByIdProvider(widget.tripId),
    );

    final activityState = ref.watch(
      activityControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Activity',
        ),
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
              child: Text(
                'Trip not found',
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity information',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller:
                          _titleController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Activity title',
                        hintText:
                            'Visit Tokyo Tower',
                        prefixIcon: Icon(
                          Icons
                              .local_activity_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Please enter an activity title';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _locationController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Location',
                        hintText:
                            'Tokyo Tower',
                        prefixIcon: Icon(
                          Icons
                              .location_on_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Please enter a location';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Schedule',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(height: 16),

                    _SelectorField(
                      label: 'Date',
                      value: _formatDate(
                        _selectedDate,
                      ),
                      icon: Icons
                          .calendar_today_outlined,
                      onTap: () {
                        _selectDate(
                          trip.startDate,
                          trip.endDate,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _SelectorField(
                      label: 'Time',
                      value: _formatTime(
                        _selectedTime,
                      ),
                      icon:
                          Icons.access_time,
                      onTap: _selectTime,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _noteController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Note (optional)',
                        hintText:
                            'Buy tickets online...',
                        alignLabelWithHint:
                            true,
                        prefixIcon: Icon(
                          Icons.notes_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed:
                          activityState.isLoading
                              ? null
                              : _createActivity,
                      child:
                          activityState.isLoading
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
                                  'Add Activity',
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

class _SelectorField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectorField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(value),
      ),
    );
  }
}