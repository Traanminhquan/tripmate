import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/trip.dart';
import '../../providers/trip_provider.dart';

class EditTripScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const EditTripScreen({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<EditTripScreen> createState() =>
      _EditTripScreenState();
}

class _EditTripScreenState
    extends ConsumerState<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _destinationController;
  late final TextEditingController _countryController;

  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.trip.title,
    );

    _destinationController = TextEditingController(
      text: widget.trip.destination,
    );

    _countryController = TextEditingController(
      text: widget.trip.country,
    );

    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (result == null) return;

    setState(() {
      _startDate = result;

      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
    });
  }

  Future<void> _selectEndDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );

    if (result == null) return;

    setState(() {
      _endDate = result;
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(tripControllerProvider.notifier)
        .updateTrip(
          trip: widget.trip,
          title: _titleController.text.trim(),
          destination: _destinationController.text.trim(),
          country: _countryController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        );

    final state = ref.read(
      tripControllerProvider,
    );

    if (!mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update trip: ${state.error}',
          ),
        ),
      );

      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(
      tripControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Trip'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Update trip information',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Trip title',
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter trip title';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter destination';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(
                      Icons.public_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter country';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Travel dates',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),

                const SizedBox(height: 16),

                _DateField(
                  label: 'Start date',
                  value:
                      _formatDate(_startDate),
                  onTap: _selectStartDate,
                ),

                const SizedBox(height: 12),

                _DateField(
                  label: 'End date',
                  value:
                      _formatDate(_endDate),
                  onTap: _selectEndDate,
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed:
                      tripState.isLoading
                          ? null
                          : _save,
                  child: tripState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
          ),
        ),
        child: Text(value),
      ),
    );
  }
}