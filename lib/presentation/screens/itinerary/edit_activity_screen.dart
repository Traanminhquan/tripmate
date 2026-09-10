import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/trip_activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/trip_provider.dart';

class EditActivityScreen
    extends ConsumerStatefulWidget {
  final TripActivity activity;

  const EditActivityScreen({
    super.key,
    required this.activity,
  });

  @override
  ConsumerState<EditActivityScreen> createState() =>
      _EditActivityScreenState();
}

class _EditActivityScreenState
    extends ConsumerState<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.activity.title,
    );

    _locationController = TextEditingController(
      text: widget.activity.location,
    );

    _noteController = TextEditingController(
      text: widget.activity.note ?? '',
    );

    _selectedDate = widget.activity.date;

    final timeParts =
        widget.activity.startTime.split(':');

    _selectedTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 9,
      minute: timeParts.length > 1
          ? int.tryParse(timeParts[1]) ?? 0
          : 0,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: startDate,
      lastDate: endDate,
    );

    if (result == null) return;

    setState(() {
      _selectedDate = result;
    });
  }

  Future<void> _selectTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (result == null) return;

    setState(() {
      _selectedTime = result;
    });
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(activityControllerProvider.notifier)
        .updateActivity(
          activity: widget.activity,
          title: _titleController.text.trim(),
          location:
              _locationController.text.trim(),
          date: _selectedDate,
          startTime:
              _formatTime(_selectedTime),
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
            'Failed to update activity: ${state.error}',
          ),
        ),
      );

      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(
      activityControllerProvider,
    );

    final tripAsync = ref.watch(
      tripByIdProvider(
        widget.activity.tripId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Activity',
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
                  children: [
                    TextFormField(
                      controller:
                          _titleController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Activity title',
                        prefixIcon: Icon(
                          Icons
                              .local_activity_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter activity title';
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
                        prefixIcon: Icon(
                          Icons
                              .location_on_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter location';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _SelectorField(
                      label: 'Date',
                      value:
                          _formatDate(_selectedDate),
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
                      value:
                          _formatTime(_selectedTime),
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
                        prefixIcon: Icon(
                          Icons.notes_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed:
                          controllerState.isLoading
                              ? null
                              : _save,
                      child:
                          controllerState.isLoading
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