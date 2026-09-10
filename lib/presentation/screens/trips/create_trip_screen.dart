import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/trip_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() =>
      _CreateTripScreenState();
}

class _CreateTripScreenState
    extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _countryController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

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
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (result == null) return;

    setState(() {
      _startDate = result;

      if (_endDate != null &&
          _endDate!.isBefore(result)) {
        _endDate = null;
      }
    });
  }

  Future<void> _selectEndDate() async {
    final startDate = _startDate;

    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select start date first.',
          ),
        ),
      );
      return;
    }

    final result = await showDatePicker(
      context: context,
      initialDate: _endDate ?? startDate,
      firstDate: startDate,
      lastDate: DateTime(2035),
    );

    if (result == null) return;

    setState(() {
      _endDate = result;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select start and end dates.',
          ),
        ),
      );
      return;
    }

    final tripId = await ref
        .read(tripControllerProvider.notifier)
        .createTrip(
          title: _titleController.text.trim(),
          destination:
              _destinationController.text.trim(),
          country: _countryController.text.trim(),
          startDate: _startDate!,
          endDate: _endDate!,
        );

    final state =
        ref.read(tripControllerProvider);

    if (!mounted) return;

    if (state.hasError || tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create trip: ${state.error ?? ''}',
          ),
        ),
      );

      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tripState =
        ref.watch(tripControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
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
                  'Trip information',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Trip title',
                    hintText: 'Japan Adventure',
                    prefixIcon:
                        Icon(Icons.edit_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a trip title';
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
                    hintText: 'Tokyo',
                    prefixIcon:
                        Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a destination';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'Japan',
                    prefixIcon:
                        Icon(Icons.public_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a country';
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
                          : _createTrip,
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
                          'Create Trip',
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
          prefixIcon:
              const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}